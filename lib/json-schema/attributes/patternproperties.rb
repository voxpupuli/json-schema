module JSON
  class Schema
    class PatternPropertiesAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if data.is_a?(Hash)
          current_schema.schema['patternProperties'].each do |property,property_schema|
            r = Regexp.new(property)

            # Check each key in the data hash to see if it matches the regex
            data.each do |key,value|
              if r.match(key)
                schema = JSON::Schema.new(property_schema,current_schema.uri,validator)
                fragments << key
                schema.validate(data[key],fragments,options)
                fragments.pop
              end
            end
          end
        end
      end
    end
  end
end