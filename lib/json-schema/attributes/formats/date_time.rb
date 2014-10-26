require 'json-schema/attribute'

module JSON
  class Schema
    class DateTimeFormat < FormatAttribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        # Timestamp in restricted ISO-8601 YYYY-MM-DDThh:mm:ssZ with optional decimal fraction of the second
        if data.is_a?(String)
          error_message = "The property '#{build_fragment(fragments)}' must be a date/time in the ISO-8601 format of YYYY-MM-DDThh:mm:ssZ or YYYY-MM-DDThh:mm:ss.ssZ"
          r = Regexp.new('^\d\d\d\d-\d\d-\d\dT(\d\d):(\d\d):(\d\d)([\.,]\d+)?(Z|[+-](\d\d)(:?\d\d)?)?$')
          if (m = r.match(data))
            parts = data.split("T")
            begin
              Date.parse(parts[0])
            rescue Exception
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
              return
            end
            begin
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if m[1].to_i > 23
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if m[2].to_i > 59
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if m[3].to_i > 59
            rescue Exception
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
              return
            end
          else
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
            return
          end
        end
      end
    end
  end
end
