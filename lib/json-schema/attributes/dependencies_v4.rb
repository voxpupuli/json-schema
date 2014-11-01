require 'json-schema/attribute'

module JSON
  class Schema
    class DependenciesV4Attribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(Hash)

        current_schema.schema['dependencies'].each do |property, dependency_value|
          next unless data.has_key?(property.to_s)

          case dependency_value
          when Array
            dependency_value.each do |value|
              if !data.has_key?(value.to_s)
                message = "The property '#{build_fragment(fragments)}' has a property '#{property}' that depends on a missing property '#{value}'"
                validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
              end
            end
          when Hash
            schema = JSON::Schema.new(dependency_value, current_schema.uri, validator)
            schema.validate(data, fragments, processor, options)
          end
        end
      end
    end
  end
end
