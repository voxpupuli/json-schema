require 'json-schema/attribute'

module JSON
  class Schema
    class RequiredAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(Hash)

        schema = current_schema.schema
        defined_properties = schema['properties']

        schema['required'].each do |property, property_schema|
          next if data.has_key?(property.to_s)
          prop_defaults = options[:insert_defaults] &&
                          defined_properties &&
                          defined_properties[property] &&
                          !defined_properties[property]["default"].nil? &&
                          !defined_properties[property]["readonly"]

          if !prop_defaults
            schema_property = schema['properties'][property]
            message = fragments.present? && schema_property.has_key?('invalidMessage') ? schema_property['invalidMessage'] : "'#{property}' is missing"
            validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end
    end
  end
end
