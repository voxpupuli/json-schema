require 'json-schema/attribute'

module JSON
  class Schema
    class MaxLengthAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(String)

        max_length = current_schema.schema['maxLength']
        if data.length > max_length
          message = "The property '#{build_fragment(fragments)}' was not of a maximum string length of #{max_length}"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
