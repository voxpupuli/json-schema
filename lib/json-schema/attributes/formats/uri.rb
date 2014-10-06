require 'json-schema/attribute'
require 'uri'
module JSON
  class Schema
    class UriFormat < FormatAttribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(String)
          error_message = "The property '#{build_fragment(fragments)}' must be a valid URI"
          begin
            URI.parse(URI.escape(data))
          rescue URI::InvalidURIError
            validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end
    end
  end
end
