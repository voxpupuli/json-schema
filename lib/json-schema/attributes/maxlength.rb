module JSON
  class Schema
    class MaxLengthAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if data.is_a?(String)
          if data.length > current_schema.schema['maxLength']
            message = "The property '#{build_fragment(fragments)}' was not of a maximum string length of #{current_schema.schema['maxLength']}"
            validation_error(message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end
    end
  end
end