require 'json-schema/attribute'

module JSON
  class Schema
    class AdditionalItemsAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        return unless data.is_a?(Array)

        schema = current_schema.schema
        return unless schema['items'].is_a?(Array)

        if schema['additionalItems'] == false && schema['items'].length != data.length
          message = "The property '#{build_fragment(fragments)}' contains additional array elements outside of the schema when none are allowed"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        elsif schema['additionalItems'].is_a?(Hash)
          additional_items_schema = JSON::Schema.new(schema['additionalItems'], current_schema.uri, validator)
          data.each_with_index do |item,i|
            if i >= schema['items'].length
              fragments << i.to_s
              additional_items_schema.validate(item, fragments, processor, options)
              fragments.pop
            end
          end
        end
      end
    end
  end
end
