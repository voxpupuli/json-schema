module JSON
  class Schema
    class TypeV4Attribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        union = true

        if !types.is_a?(Array)
          types = [types]
          union = false
        end
        valid = false

        # Create an array to hold errors that are generated during union validation
        union_errors = []

        types.each do |type|
          valid = data_valid_for_type?(data, type)
          break if valid
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