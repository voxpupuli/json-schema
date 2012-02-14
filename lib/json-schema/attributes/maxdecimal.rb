module JSON
  class Schema
    class MaxDecimalAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if data.is_a?(Numeric)
          s = data.to_s.split(".")[1]
          if s && s.length > current_schema.schema['maxDecimal']
            message = "The property '#{build_fragment(fragments)}' had more decimal places than the allowed #{current_schema.schema['maxDecimal']}"
            validation_error(message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end
    end
  end
end