require 'json-schema/attribute'

module JSON
  class Schema
    class MaxPropertiesAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(Hash) && (data.size > current_schema.schema['maxProperties'])
          message = "The property '#{build_fragment(fragments)}' did not contain a minimum number of properties #{current_schema.schema['maxProperties']}"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
