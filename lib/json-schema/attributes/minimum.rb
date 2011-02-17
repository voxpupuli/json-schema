module JSON
  class Schema
    class MinimumAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if data.is_a?(Numeric)
          if (current_schema.schema['exclusiveMinimum'] ? data <= current_schema.schema['minimum'] : data < current_schema.schema['minimum'])
            message = "The property '#{build_fragment(fragments)}' did not have a minimum value of #{current_schema.schema['minimum']}, "
            message += current_schema.schema['exclusiveMinimum'] ? 'exclusively' : 'inclusively'
            raise ValidationError.new(message, fragments, current_schema)
          end
        end
      end
    end
  end
end