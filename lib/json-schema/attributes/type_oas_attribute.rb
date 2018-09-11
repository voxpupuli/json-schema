require 'json-schema/attributes/type_v4'

module JSON
  class Schema
    class TypeOasAttrbiute < TypeV4Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        nullable = current_schema.schema['nullable']
        current_schema.schema['type'] = ([current_schema.schema['type']] << 'null').flatten if nullable
        super(current_schema, data, fragments, processor, validator, options)
      end
    end
  end
end
