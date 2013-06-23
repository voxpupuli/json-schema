module JSON
  class Schema
    class MultipleOfAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(Numeric)
          if current_schema.schema['multipleOf'] == 0 ||
             current_schema.schema['multipleOf'] == 0.0 ||
             (BigDecimal.new(data.to_s) % BigDecimal.new(current_schema.schema['multipleOf'].to_s)).to_f != 0
             message = "The property '#{build_fragment(fragments)}' was not divisible by #{current_schema.schema['multipleOf']}"
             validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end
    end
  end
end