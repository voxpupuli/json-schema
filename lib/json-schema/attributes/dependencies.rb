require 'json-schema/attribute'

module JSON
  class Schema
    class DependenciesAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(Hash)
          current_schema.schema['dependencies'].each do |property,dependency_value|
            if data.has_key?(property.to_s)
              if dependency_value.is_a?(String)
                if !data.has_key?(dependency_value.to_s)
                  message = "The property '#{build_fragment(fragments)}' has a property '#{property}' that depends on a missing property '#{dependency_value}'"
                  validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
                end
              elsif dependency_value.is_a?(Array)
                dependency_value.each do |value|
                  if !data.has_key?(value.to_s)
                    message = "The property '#{build_fragment(fragments)}' has a property '#{property}' that depends on a missing property '#{value}'"
                    validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
                  end
                end
              else
                schema = JSON::Schema.new(dependency_value,current_schema.uri,validator)
                schema.validate(data, fragments, processor, options)
              end
            end
          end
        end
      end
    end
  end
end
