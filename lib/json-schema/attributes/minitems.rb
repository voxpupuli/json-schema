module JSON
  class Schema
    class MinItemsAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if data.is_a?(Array) && (data.compact.size < current_schema.schema['minItems'])
          message = "The property '#{build_fragment(fragments)}' did not contain a minimum number of items #{current_schema.schema['minItems']}"
          raise ValidationError.new(message, fragments, current_schema)
        end
      end
    end
  end
end