module JSON
  class Schema
    class PropertiesV4Attribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(Hash)
          current_schema.schema['properties'].each do |property,property_schema|
            if !data.has_key?(property.to_s) &&
               !data.has_key?(property.to_sym) &&
               property_schema['default'] &&
               !property_schema['readonly'] &&
               options[:insert_defaults]
              default = property_schema['default']
              data[property] = (default.is_a?(Hash) ? default.clone : default)
            end

            if data.has_key?(property.to_s)
              schema = JSON::Schema.new(property_schema,current_schema.uri,validator)
              fragments << property
              schema.validate(data[property],fragments,processor,options)
              fragments.pop
            end
          end
        end
      end
    end
  end
end
