require 'json-schema/attribute'

module JSON
  class Schema
    class DateTimeV4Format < FormatAttribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(String)
          error_message = "The property '#{build_fragment(fragments)}' must be a valid RFC3339 date/time string"
          begin
            DateTime.rfc3339(data)
          rescue ArgumentError
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end
    end
  end
end
