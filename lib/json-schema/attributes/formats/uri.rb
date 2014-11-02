require 'json-schema/attribute'
require 'addressable/uri'
module JSON
  class Schema
    class UriFormat < FormatAttribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(String)
        begin
          Addressable::URI.parse(Addressable::URI.escape(data))
        rescue Addressable::URI::InvalidURIError
          validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
