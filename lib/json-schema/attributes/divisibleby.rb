module JSON
  class Schema
    class DivisibleByAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if data.is_a?(Numeric)
          if current_schema.schema['divisibleBy'] == 0 || 
             current_schema.schema['divisibleBy'] == 0.0 ||
             (BigDecimal.new(data.to_s) % BigDecimal.new(current_schema.schema['divisibleBy'].to_s)).to_f != 0
             message = "The property '#{build_fragment(fragments)}' was not divisible by #{current_schema.schema['divisibleBy']}"
             validation_error(message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end
    end
  end
end