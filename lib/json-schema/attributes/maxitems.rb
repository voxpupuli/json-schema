module JSON
  class Schema
    class MaxItemsAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if data.is_a?(Array) && (data.compact.size > current_schema.schema['maxItems'])
          message = "The property '#{build_fragment(fragments)}' did not contain a minimum number of items #{current_schema.schema['minItems']}"
          validation_error(message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end