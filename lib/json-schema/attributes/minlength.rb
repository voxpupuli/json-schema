module JSON
  class Schema
    class MinLengthAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if data.is_a?(String)
          if data.length < current_schema.schema['minLength']
            message = "The property '#{build_fragment(fragments)}' was not of a minimum string length of #{current_schema.schema['minLength']}"
            validation_error(message, fragments, current_schema, options[:record_options])
          end
        end
      end
    end
  end
end