require 'json-schema/attribute'

module JSON
  class Schema
    class TypeV4Attribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        union = true
        schema = current_schema.schema
        types = schema['type']
        if !types.is_a?(Array)
          types = [types]
          union = false
        end

        return if types.any? { |type| data_valid_for_type?(data, type) }

        types = types.map { |type| type.is_a?(String) ? type : '(schema)' }.join(', ')
        message = if schema['invalidMessage'].present?
          schema['invalidMessage']
        else
          format( "#{fragments.join('/')} must be '%s'", types)
        end
        validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
      end
    end
  end
end
