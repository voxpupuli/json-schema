require 'json-schema/attribute'

module JSON
  class Schema
    class MinPropertiesAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(Hash)

        min_properties = current_schema.schema['minProperties']
        if data.size < min_properties
          message = "The property '#{build_fragment(fragments)}' did not contain a minimum number of properties #{min_properties}"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
