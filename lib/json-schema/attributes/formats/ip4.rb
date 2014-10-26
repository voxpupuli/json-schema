require 'json-schema/attribute'
require 'uri'
module JSON
  class Schema
    class IP4Format < FormatAttribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(String)
          error_message = "The property '#{build_fragment(fragments)}' must be a valid IPv4 address"
          r = Regexp.new('^(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}\.(\d+){1,3}$')
          if (m = r.match(data))
            1.upto(4) do |x|
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if m[x].to_i > 255
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
