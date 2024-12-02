require 'json-schema/errors/validation_error'

module JSON
  class Schema
    class Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {}); end

      def self.build_fragment(fragments)
        "#/#{fragments.join('/')}"
      end

      def self.validation_error(processor, message, fragments, current_schema, failed_attribute, record_errors)
        error = ValidationError.new(message, fragments, failed_attribute, current_schema)
        if record_errors
          processor.validation_error(error)
        else
          raise error
        end
      end

      def self.validation_errors(validator)
        validator.validation_errors
      end

      TYPE_CLASS_MAPPINGS = {
        'string' => String,
        'number' => Numeric,
        'integer' => Integer,
        'boolean' => [TrueClass, FalseClass],
        'object' => Hash,
        'array' => Array,
        'null' => NilClass,
        'any' => Object,
      }

      def self.data_valid_for_type?(data, type, nullable: false)
        valid_classes = TYPE_CLASS_MAPPINGS.fetch(type) { return true }
        valid_classes = [valid_classes, NilClass] if nullable
        valid_classes.flatten! if valid_classes.is_a?(Array)
        Array(valid_classes).any? { |c| data.is_a?(c) }
      end

      # Lookup Schema type of given class instance
      def self.type_of_data(data)
        type, = TYPE_CLASS_MAPPINGS.map { |k, v| [k, v] }.sort_by do |(_, v)|
          -Array(v).map { |klass| klass.ancestors.size }.max
        end.find do |(_, v)|
          Array(v).any? { |klass| data.is_a?(klass) }
        end
        type
      end
    end
  end
end
