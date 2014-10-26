module JSON
  class Schema
    class Validator
      attr_accessor :attributes, :formats, :uri, :names, :metaschema

      def initialize()
        @attributes = {}
        @uri = nil
        @names = []
        @metaschema = ''
      end

      def extend_schema_definition(schema_uri)
        validator = JSON::Validator.validator_for(schema_uri)
        @attributes.merge!(validator.attributes)
      end

      def validate(current_schema, data, fragments, processor, options = {})
        current_schema.schema.each do |attr_name,attribute|
          if @attributes.has_key?(attr_name.to_s)
            @attributes[attr_name.to_s].validate(current_schema, data, fragments, processor, self, options)
          end
        end
        data
      end
    end
  end
end
