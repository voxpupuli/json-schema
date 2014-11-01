require 'json-schema/attribute'

module JSON
  class Schema
    class MaximumAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(Numeric)

        schema    = current_schema.schema
        exclusive = schema['exclusiveMaximum']
        maximum   = schema['maximum']

        invalid = exclusive ? data >= maximum : data > maximum
        if invalid
          message = "The property '#{build_fragment(fragments)}' did not have a maximum value of #{maximum}, "
          message += exclusive ? 'exclusively' : 'inclusively'
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
