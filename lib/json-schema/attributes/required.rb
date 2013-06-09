module JSON
  class Schema
    class RequiredAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        if data.is_a?(Hash)
          current_schema.schema['required'].each do |property,property_schema|
            if !data.has_key?(property)
              message = "The property '#{build_fragment(fragments)}' did not contain a required property of '#{property}'"
              validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
            end
          end
        end
      end
    end
  end
end
