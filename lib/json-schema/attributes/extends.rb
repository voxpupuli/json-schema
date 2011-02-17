module JSON
  class Schema
    class ExtendsAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        schemas = current_schema.schema['extends']
        schemas = [schemas] if !schemas.is_a?(Array)
        schemas.each do |s|
          schema = JSON::Schema.new(s,current_schema.uri,validator)
          schema.validate(data, fragments)
        end
      end
    end
  end
end