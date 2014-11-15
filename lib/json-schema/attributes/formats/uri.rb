require 'json-schema/attribute'
require 'uri'
module JSON
  class Schema
    class UriFormat < FormatAttribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(String)

        begin
          URI.parse(URI.escape(data))
        rescue URI::InvalidURIError
          error_message = "The property '#{build_fragment(fragments)}' must be a valid URI"
          validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
