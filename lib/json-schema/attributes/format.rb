require 'json-schema/attribute'
require 'uri'

module JSON
  class Schema
    class FormatAttribute < Attribute

      def self.reset_default_validators
        @@format_validators = {
          'date-time' => DateTimeFormat,
          'date' => DateFormat,
          'time' => TimeFormat,
          'ipv4' => IP4Format,
          'ip-address' => IP4Format,
          'ipv6' => IP6Format,
          'uri' => UriFormat

        }
      end

      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        validator = @@format_validators[current_schema.schema['format']]
        validator.validate(current_schema, data, fragments, processor, validator, options = {}) unless validator.nil?
      end
    end
  end
end
