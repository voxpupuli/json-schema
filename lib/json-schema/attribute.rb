require 'json-schema/errors/validation_error'

module JSON
  class Schema
    class Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
      end

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
    end
  end
end
