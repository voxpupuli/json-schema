require 'json-schema/attribute'
require 'ipaddr'

module JSON
  class Schema
    class IP6Format < FormatAttribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(String)

        error_message = "The property '#{build_fragment(fragments)}' must be a valid IPv6 address"
        begin
          ip = IPAddr.new data
        rescue ArgumentError => e
          raise e unless e.message == 'invalid address'
        end
        validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors]) unless ip && ip.ipv6?
      end
    end
  end
end
