require 'json-schema/attribute'
require 'uri'
module JSON
  class Schema
    class TimeFormat < FormatAttribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(String)
          error_message = "The property '#{build_fragment(fragments)}' must be a time in the format of hh:mm:ss"
          r = Regexp.new('^(\d\d):(\d\d):(\d\d)$')
          if (m = r.match(data))
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if m[1].to_i > 23
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if m[2].to_i > 59
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if m[3].to_i > 59
          else
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
            return
          end
        end
      end
    end
  end
end
