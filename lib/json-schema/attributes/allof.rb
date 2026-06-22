require 'json-schema/attribute'

module JSON
  class Schema
    class AllOfAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        valid = true
        message = nil

        # We get the properties that were explicity defined in this schema so we can ignore undefined property errors in sub schemas
        defined_properties = current_schema.schema['allOf'].collect do |subschema|
          if subschema.is_a?(Hash) && subschema.key?('properties') && subschema['properties'].is_a?(Hash)
            subschema['properties'].keys.map(&:to_s)
          else
            []
          end
        end.flatten

        current_schema.schema['allOf'].each_with_index do |element, _schema_index|
          schema = JSON::Schema.new(element, current_schema.uri, validator)

          begin
            # Cannot raise if noAdditionalProperties is true, we need to
            # evaluate each sub schema within the allOf, before raising.
            if options[:noAdditionalProperties] == true
              schema.validate(data, fragments, processor, options.merge(record_errors: true, allOf_branch: true))
            else
              schema.validate(data, fragments, processor, options)
            end
          rescue ValidationError => e
            valid = false
            message = e.message
          end
        end

        # If we have a undefined property error from a sub schema and that property was
        # defined here, we remove it from undefined properties and discard errors if all
        # properties are accounted for.
        undefined_attribute_errors = []
        validation_errors(processor).reject! do |error|
          if error.failed_attribute == JSON::Schema::PropertiesV4Attribute
            error.properties -= defined_properties
            undefined_attribute_errors << error
            error.properties.empty?
          else
            false
          end
        end

        # If this method has been called recursively, we don't want to process
        # validation errors yet, as we'll need to aggregate them at the top level
        # to find the common undefined properties.
        return if options[:allOf_branch] == true

        # Find any properties that are undefined across all subschemas.
        common_undefined_properties = {}
        if options[:noAdditionalProperties] == true && undefined_attribute_errors.any?
          all_property_errors = undefined_attribute_errors.map(&:properties)
          common_undefined_properties = (all_property_errors.first || []).to_set

          all_property_errors[1..].each do |curr_property_errors|
            common_undefined_properties &= curr_property_errors.to_set
          end
        end

        # PropertiesV4Attribute represents errors that would indicate an
        # additional property was detected. If we filter these out, we should
        # be left with errors that are not dependent on any other sub schema.
        validation_errors(processor).reject! do |error|
          error.failed_attribute == JSON::Schema::PropertiesV4Attribute
        end

        if !valid || !common_undefined_properties.empty? || !validation_errors(processor).empty?
          message ||= "The property '#{build_fragment(fragments)}' of type #{type_of_data(data)} did not match all of the required schemas"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
