require 'json-schema/attribute'

module JSON
  class Schema
    class DateV4Format < FormatAttribute
      REGEXP = /\A\d{4}-\d{2}-\d{2}\z/

      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(String)
          schema = current_schema.schema
          default_error_message = "The property '#{build_fragment(fragments)}' must be a date in the format of YYYY-MM-DD"
          error_message = schema['invalidMessage'].present? ? schema['invalidMessage'] : default_error_message

          if REGEXP.match(data)
            begin
              Date.parse(data)
            rescue ArgumentError => e
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
            end
          else
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end
    end
  end
end
