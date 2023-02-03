require 'json-schema/attribute'

module JSON
  class Schema
    class ConstAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        const_value = current_schema.schema['const']
        unless const_value == data
          message = "The property '#{build_fragment(fragments)}' value #{data.inspect} did not match constant '#{const_value}'"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
