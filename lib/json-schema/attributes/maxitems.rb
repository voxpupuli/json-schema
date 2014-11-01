require 'json-schema/attribute'

module JSON
  class Schema
    class MaxItemsAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(Array)

        max_items = current_schema.schema['maxItems']
        if data.size > max_items
          message = "The property '#{build_fragment(fragments)}' had more items than the allowed #{max_items}"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
