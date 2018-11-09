require 'json-schema/attribute'

module JSON
  class Schema
    class ConstAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        const = current_schema.schema['const']
        return if const == data

        message = "The property '#{build_fragment(fragments)}' value #{data.inspect} did not match const value: #{const}"
        validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
      end
    end
  end
end
