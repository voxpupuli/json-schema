require 'json-schema/attribute'

module JSON
  class Schema
    class TypeV4Attribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        union = true
        types = current_schema.schema['type']
        if !types.is_a?(Array)
          types = [types]
          union = false
        end
        valid = false

        types.each do |type|
          valid = data_valid_for_type?(data, type)
          break if valid
        end

        if !valid
          if union
            message = "The property '#{build_fragment(fragments)}' of type #{data.class} did not match one or more of the following types:"
            types.each {|type| message += type.is_a?(String) ? " #{type}," : " (schema)," }
            message.chop!
            validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
          else
            message = "The property '#{build_fragment(fragments)}' of type #{data.class} did not match the following type:"
            types.each {|type| message += type.is_a?(String) ? " #{type}," : " (schema)," }
            message.chop!
            validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end

      TYPE_CLASS_MAPPINGS = {
        "string" => String,
        "number" => Numeric,
        "integer" => Integer,
        "boolean" => [TrueClass, FalseClass],
        "object" => Hash,
        "array" => Array,
        "null" => NilClass,
        "any" => Object
      }

      def self.data_valid_for_type?(data, type)
        valid_classes = TYPE_CLASS_MAPPINGS.fetch(type) { return true }
        Array(valid_classes).any? { |c| data.is_a?(c) }
      end
    end
  end
end
