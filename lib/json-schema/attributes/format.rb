require 'json-schema/attribute'
require 'uri'

module JSON
  class Schema
    class FormatAttribute < Attribute

      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if TypeAttribute.data_valid_for_type?(data, current_schema.schema['type'])
          validator = validator.formats[current_schema.schema['format'].to_s]
          validator.validate(current_schema, data, fragments, processor, validator, options) unless validator.nil?
        end
      end
    end
  end
end
