module JSON
  class Schema
    class PropertiesOptionalAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(Hash)
          current_schema.schema['properties'].each do |property,property_schema|
            if ((property_schema['optional'].nil? || property_schema['optional'] == false) && !data.has_key?(property.to_s) && !data.has_key?(property.to_sym))
              message = "The property '#{build_fragment(fragments)}' did not contain a required property of '#{property}'"
              validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
            end

            if data.has_key?(property.to_s) || data.has_key?(property.to_sym)
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