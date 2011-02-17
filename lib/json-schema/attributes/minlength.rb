module JSON
  class Schema
    class MinLengthAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if data.is_a?(String)
          if data.length < current_schema.schema['minLength']
            message = "The property '#{build_fragment(fragments)}' was not of a minimum string length of #{current_schema.schema['minLength']}"
            raise ValidationError.new(message, fragments, current_schema)
          end
        end
      end
    end
  end
end