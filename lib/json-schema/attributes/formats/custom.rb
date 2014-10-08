require 'json-schema/attribute'
require 'json-schema/errors/custom_format_error'

require 'uri'
module JSON
  class Schema
    class CustomFormat < FormatAttribute
      def initialize(validation_proc)
        @validation_proc = validation_proc
      end

      def validate(current_schema, data, fragments, processor, validator, options = {})
        begin
          @validation_proc.call data
        rescue JSON::Schema::CustomFormatError => e
          self.class.validation_error(processor, e.message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
