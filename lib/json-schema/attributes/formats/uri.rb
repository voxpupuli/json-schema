require 'json-schema/attribute'
require 'addressable/uri'
module JSON
  class Schema
    class UriFormat < FormatAttribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(String)
        error_message = "The property '#{build_fragment(fragments)}' must be a valid URI"
        begin
          # TODO
          # Addressable only throws an exception on to_s for invalid URI strings, although it
          # probably should throughout parse already - change this when there is news from Addressable
          Addressable::URI.parse(data).to_s
        rescue Addressable::URI::InvalidURIError
          validation_error(processor, error_message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
