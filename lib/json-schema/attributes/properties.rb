module JSON
  class Schema
    class PropertiesAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if data.is_a?(Hash)
          current_schema.schema['properties'].each do |property,property_schema|
            if (property_schema['required'] && !data.has_key?(property))
              message = "The property '#{build_fragment(fragments)}' did not contain a required property of '#{property}'"
              validation_error(message, fragments, current_schema, self, options[:record_errors])
            end
          
            if data.has_key?(property)
              schema = JSON::Schema.new(property_schema,current_schema.uri,validator)
              fragments << property
              schema.validate(data[property],fragments,options)
              fragments.pop
            end
          end
        end
      end
    end
  end
end