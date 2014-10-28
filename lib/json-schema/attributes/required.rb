require 'json-schema/attribute'

module JSON
  class Schema
    class RequiredAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(Hash)
          current_schema.schema['required'].each do |property,property_schema|
            if !data.has_key?(property.to_s)
              prop_defaults = options[:insert_defaults] &&
                              current_schema.schema['properties'] &&
                              current_schema.schema['properties'][property] &&
                              !current_schema.schema['properties'][property]["default"].nil? &&
                              !current_schema.schema['properties'][property]["readonly"]
              if !prop_defaults
                message = "The property '#{build_fragment(fragments)}' did not contain a required property of '#{property}'"
                validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
              end
            end
          end
        end
      end
    end
  end
end
