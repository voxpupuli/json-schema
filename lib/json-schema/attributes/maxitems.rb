require 'json-schema/attribute'

module JSON
  class Schema
    class MaxItemsAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(Array) && (data.compact.size > current_schema.schema['maxItems'])
          message = "The property '#{build_fragment(fragments)}' had more items than the allowed #{current_schema.schema['maxItems']}"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
