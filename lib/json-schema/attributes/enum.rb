require 'json-schema/attribute'

module JSON
  class Schema
    class EnumAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, _validator, options = {})
        enum = current_schema.schema['enum']
        return if enum.include?(data)

        values = enum.map do |val|
          case val
          when nil   then 'null'
          when Array then 'array'
          when Hash  then 'object'
          else val.to_s
          end
        end.join(', ')

        message = "The property '#{build_fragment(fragments)}' value #{data.inspect} did not match one of the following values: #{values}"
        validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
      end
    end
  end
end
