require 'json-schema/attribute'

module JSON
  class Schema
    class MinItemsAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(Array)

        min_items = current_schema.schema['minItems']
        if data.size < min_items
          message = "The property '#{build_fragment(fragments)}' did not contain a minimum number of items #{min_items}"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
