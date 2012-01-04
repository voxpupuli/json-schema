module JSON
  class Schema
    class ItemsAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if data.is_a?(Array)
           if current_schema.schema['items'].is_a?(Hash)
             data.each_with_index do |item,i|
               schema = JSON::Schema.new(current_schema.schema['items'],current_schema.uri,validator)
               fragments << i.to_s
               schema.validate(item,fragments, options)
               fragments.pop
             end
           elsif current_schema.schema['items'].is_a?(Array)
             current_schema.schema['items'].each_with_index do |item_schema,i|
               schema = JSON::Schema.new(item_schema,current_schema.uri,validator)
               fragments << i.to_s
               schema.validate(data[i],fragments, options)
               fragments.pop
             end
           end
        end
      end
    end
  end
end