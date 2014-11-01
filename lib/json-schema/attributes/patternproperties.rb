require 'json-schema/attribute'

module JSON
  class Schema
    class PatternPropertiesAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(Hash)

        current_schema.schema['patternProperties'].each do |property, property_schema|
          regexp = Regexp.new(property)

          # Check each key in the data hash to see if it matches the regex
          data.each do |key, value|
            next unless regexp.match(key)

            schema = JSON::Schema.new(property_schema, current_schema.uri, validator)
            fragments << key
            schema.validate(data[key], fragments, processor, options)
            fragments.pop
          end
        end
      end
    end
  end
end
