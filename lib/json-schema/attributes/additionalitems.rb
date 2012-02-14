module JSON
  class Schema
    class AdditionalItemsAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if data.is_a?(Array) && current_schema.schema['items'].is_a?(Array)
          if current_schema.schema['additionalItems'] == false && current_schema.schema['items'].length != data.length
            message = "The property '#{build_fragment(fragments)}' contains additional array elements outside of the schema when none are allowed"
            validation_error(message, fragments, current_schema, self, options[:record_errors])
          elsif current_schema.schema['additionalItems'].is_a?(Hash)
            schema = JSON::Schema.new(current_schema.schema['additionalItems'],current_schema.uri,validator)
            data.each_with_index do |item,i|
              if i >= current_schema.schema['items'].length
                fragments << i.to_s
                schema.validate(item, fragments, options)
                fragments.pop
              end
            end
          end
        end
      end
    end
  end
end