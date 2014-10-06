require 'json-schema/attribute'
require 'uri'
module JSON
  class Schema
    class IP6Format < FormatAttribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(String)
          error_message = "The property '#{build_fragment(fragments)}' must be a valid IPv6 address"
          r = Regexp.new('^[a-f0-9:]+$')
          if (r.match(data))
            # All characters are valid, now validate structure
            parts = data.split(":")
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if parts.length > 8
            condensed_zeros = false
            parts.each do |part|
              if part.length == 0
                validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if condensed_zeros
                condensed_zeros = true
              end
              validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) and return if part.length > 4
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
