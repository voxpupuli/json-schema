require 'json-schema/attribute'

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
              data[property.to_s] = (default.is_a?(Hash) ? default.clone : default)
            end

            if (options[:strict] == true && !data.has_key?(property.to_s) && !data.has_key?(property.to_sym))
              message = "The property '#{build_fragment(fragments)}' did not contain a required property of '#{property}'"
              validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
            end

            if data.has_key?(property.to_s) || data.has_key?(property.to_sym)
              schema = JSON::Schema.new(property_schema,current_schema.uri,validator)
              fragments << property.to_s
              schema.validate(data[property.to_s],fragments,processor,options)
              fragments.pop
            end
          end
        end

        # When strict is true, ensure no undefined properties exist in the data
        if (options[:strict] == true && !current_schema.schema.has_key?('additionalProperties'))
          diff = data.select do |k,v|
            if current_schema.schema.has_key?('patternProperties')
              match = false
              current_schema.schema['patternProperties'].each do |property,property_schema|
                r = Regexp.new(property)
                if r.match(k)
                  match = true
                  break
                end
              end

              !current_schema.schema['properties'].has_key?(k.to_s) && !current_schema.schema['properties'].has_key?(k.to_sym) && !match
            else
              !current_schema.schema['properties'].has_key?(k.to_s) && !current_schema.schema['properties'].has_key?(k.to_sym)
            end
          end

          if diff.size > 0
            message = "The property '#{build_fragment(fragments)}' contained undefined properties: '#{diff.keys.join(", ")}'"
            validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end
    end
  end
end
