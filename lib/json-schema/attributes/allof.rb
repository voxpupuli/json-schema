require 'json-schema/attribute'

module JSON
  class Schema
    class AllOfAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        # Create an hash to hold errors that are generated during validation
        errors = Hash.new { |hsh, k| hsh[k] = [] }
        valid = true
        message = nil

        current_schema.schema['allOf'].each_with_index do |element, schema_index|
          schema = JSON::Schema.new(element, current_schema.uri, validator)

          # We're going to add a little cruft here to try and maintain any validation errors that occur in the allOf
          # We'll handle this by keeping an error count before and after validation, extracting those errors and pushing them onto an error array
          pre_validation_error_count = validation_errors(processor).count

          begin
            # Cannot raise if noAdditionalProperties is true, we need to
            # evaluate each sub schema within the allOf, before raising.
            if options[:noAdditionalProperties] == true
              schema.validate(data, fragments, processor, options.merge(record_errors: true))
            else
              schema.validate(data, fragments, processor, options)
            end
          rescue ValidationError => e
            valid = false
            message = e.message
          end

          diff = validation_errors(processor).count - pre_validation_error_count

          while diff > 0
            diff = diff - 1
            errors["allOf ##{schema_index}"].push(validation_errors(processor).pop)
          end
        end

        # Find any properties that are common across all errors. This would
        # indicate that there is an additional property that is not defined in
        # any of the sub-schemas of allOf.
        common_properties = {}
        if options[:noAdditionalProperties] == true && !errors.empty?
          all_property_errors = errors.values.flatten.map(&:properties)
          common_properties = (all_property_errors.first || []).to_set

          all_property_errors[1..].each do |curr_property_errors|
            common_properties = common_properties & curr_property_errors.to_set
          end
        end

        if !valid || (!errors.empty? && !common_properties.empty?)
          message ||= "The property '#{build_fragment(fragments)}' of type #{type_of_data(data)} did not match all of the required schemas"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
          validation_errors(processor).last.sub_errors = errors
        end
      end
    end
  end
end
