require 'json-schema/attribute'

module JSON
  class Schema
    class MinimumAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(Numeric)

        schema    = current_schema.schema
        exclusive = schema['exclusiveMinimum']
        minimum   = schema['minimum']

        invalid = exclusive ? data <= minimum : data < minimum
        if invalid
          message = "The property '#{build_fragment(fragments)}' did not have a minimum value of #{minimum}, "
          message += exclusive ? 'exclusively' : 'inclusively'
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
