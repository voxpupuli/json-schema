require 'json-schema/attribute'

module JSON
  class Schema
    class MinItemsAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(Array) && (data.size < current_schema.schema['minItems'])
          message = "The property '#{build_fragment(fragments)}' did not contain a minimum number of items #{current_schema.schema['minItems']}"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
