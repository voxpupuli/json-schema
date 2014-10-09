require 'json-schema/attribute'
require 'uri'

module JSON
  class Schema
    class FormatAttribute < Attribute

      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if self.data_valid_for_type?(data, current_schema.schema['type'])
          format = current_schema.schema['format'].to_s
          validator = validator.formats[format] || validator.custom_formats[format]
          validator.validate(current_schema, data, fragments, processor, validator, options) unless validator.nil?
        end
      end
    end
  end
end
