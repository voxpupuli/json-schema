require 'json-schema/errors/schema_error'

module JSON
  class Schema
    class Validator
      attr_accessor :attributes, :uri

      def initialize()
        @attributes = {}
        @uri = nil
      end

      def extend_schema_definition(schema_uri)
        u = URI.parse(schema_uri)
        validator = JSON::Validator.validators["#{u.scheme}://#{u.host}#{u.path}"]
        if validator.nil?
          raise SchemaError.new("Schema not found: #{u.scheme}://#{u.host}#{u.path}")
        end
        @attributes.merge!(validator.attributes)
      end

      def to_s
        "#{@uri.scheme}://#{uri.host}#{uri.path}"
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
