require 'json-schema/attribute'

module JSON
  class Schema
    class PropertyNames < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(Hash)

        propnames = current_schema.schema['propertyNames']

        if propnames.is_a?(Hash)
          schema = JSON::Schema.new(propnames, current_schema.uri, validator)
          data.each_key do |key|
            schema.validate(key, fragments + [key], processor, options)
          end
        elsif propnames == false && data.any?
          message = "The property '#{build_fragment(fragments)}' contains additional properties #{data.keys.inspect} outside of the schema when none are allowed"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end
