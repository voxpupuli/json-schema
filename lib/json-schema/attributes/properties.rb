require 'json-schema/attributes/properties_optional'

module JSON
  class Schema
    class PropertiesAttribute < PropertiesOptionalAttribute
      def self.required?(schema, options)
        schema.fetch('required') { options[:strict] }
      end

      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(Hash)

        schema = current_schema.schema
        schema['properties'].each do |property, property_schema|
          property = property.to_s

          if !data.key?(property) &&
              options[:insert_defaults] &&
              property_schema.has_key?('default') &&
              !property_schema['readonly']
            default = property_schema['default']
            data[property] = default.is_a?(Hash) ? default.clone : default
          end

          if required?(property_schema, options) && !data.has_key?(property)
            message = "The property '#{build_fragment(fragments)}' did not contain a required property of '#{property}'"
            validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
          end

          if data.has_key?(property)
            expected_schema = JSON::Schema.new(property_schema, current_schema.uri, validator)
            expected_schema.validate(data[property], fragments + [property], processor, options)
          end
        end

        validate_unrecognized_properties(current_schema, data, fragments, processor, validator, options)
      end
    end
  end
end
