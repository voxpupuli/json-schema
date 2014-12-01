require 'json-schema/attribute'
require 'json-schema/errors/schema_error'

module JSON
  class Schema
    class RefAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        uri,schema = get_referenced_uri_and_schema(current_schema.schema, current_schema, validator)

        if schema
          schema.validate(data, fragments, processor, options)
        elsif uri
          message = "The referenced schema '#{uri.to_s}' cannot be found"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        else
          message = "The property '#{build_fragment(fragments)}' was not a valid schema"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end

      def self.get_referenced_uri_and_schema(s, current_schema, validator)
        uri = parse_uri(s, current_schema)
        target_schema = get_target_schema(uri)
        return [uri, JSON::Schema.new(target_schema,uri,validator)] if target_schema
        [uri, nil]
      end

      private

      def self.parse_uri(s, current_schema)
        uri = Addressable::URI.parse(s['$ref'])
        if uri.relative?
          uri = current_schema.uri.clone
          # Check for absolute path
          path = s['$ref'].split("#")[0]
          if path.nil? || path == ''
            uri.path = current_schema.uri.path
          elsif path[0,1] == "/"
            uri.path = Pathname.new(path).cleanpath.to_s
          else
            uri = current_schema.uri.join(path)
          end
          uri.fragment = s['$ref'].split("#")[1]
        end

        uri.fragment = "" if uri.fragment.nil?
        uri
      end

      def self.get_target_schema(uri)
        # Grab the parent schema from the schema list
        schema_key = uri.to_s.split("#")[0] + "#"
        ref_schema = JSON::Validator.schemas[schema_key]

        return nil unless ref_schema

        resolve_fragments(ref_schema.schema, uri.fragment)
      end

      def self.resolve_fragments(schema, fragment)
        return schema if fragment.empty?

        fragments = fragment.split("/").slice(1..-1)
        fragment_path = ''
        fragments.each do |fgmt|
          fgmt = Addressable::URI.unescape(fgmt)

          if schema.is_a?(Array)
            schema = schema[fgmt.to_i]
          else
            schema = schema[fgmt]
          end
          fragment_path = fragment_path + "/#{fgmt}"
        end
        schema
      end
    end
  end
end
