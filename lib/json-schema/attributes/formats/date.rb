require 'json-schema/attribute'
require 'uri'
module JSON
  class Schema
    class DateFormat < FormatAttribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(String)
          error_message = "The property '#{build_fragment(fragments)}' must be a date in the format of YYYY-MM-DD"
          r = Regexp.new('^\d\d\d\d-\d\d-\d\d$')
          if (r.match(data))
            begin
              Date.parse(data)
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
