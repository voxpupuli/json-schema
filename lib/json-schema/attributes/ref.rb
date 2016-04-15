require 'json-schema/attribute'
require 'json-schema/errors/schema_error'
require 'json-schema/util/uri'

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
        uri,schema = nil,nil

        temp_uri = JSON::Util::URI.parse(s['$ref'])
        temp_uri.defer_validation do
          if temp_uri.relative?
            temp_uri.merge!(current_schema.uri)
            # Check for absolute path
            path, fragment = s['$ref'].split("#")
            if path.nil? || path == ''
              temp_uri.path = current_schema.uri.path
            elsif path[0,1] == "/"
              temp_uri.path = Pathname.new(path).cleanpath.to_s
            else
              temp_uri.join!(path)
            end
            temp_uri.fragment = fragment
          end
          temp_uri.fragment = "" if temp_uri.fragment.nil? || temp_uri.fragment.empty?
        end

        # Grab the parent schema from the schema list
        schema_key = temp_uri.to_s.split("#")[0] + "#"

        ref_schema = JSON::Validator.schema_for_uri(schema_key)

        if ref_schema
          # Perform fragment resolution to retrieve the appropriate level for the schema
          target_schema = ref_schema.schema
          fragments = JSON::Util::URI.parse(JSON::Util::URI.unescape_uri(temp_uri)).fragment.split("/")
          fragment_path = ''
          fragments.each do |fragment|
            if fragment && fragment != ''
              fragment = fragment.gsub('~0', '~').gsub('~1', '/')
              if target_schema.is_a?(Array)
                target_schema = target_schema[fragment.to_i]
              else
                target_schema = target_schema[fragment]
              end
              fragment_path = fragment_path + "/#{fragment}"
              if target_schema.nil?
                raise SchemaError.new("The fragment '#{fragment_path}' does not exist on schema #{ref_schema.uri.to_s}")
              end
            end
          end

          # We have the schema finally, build it and validate!
          uri = temp_uri
          schema = JSON::Schema.new(target_schema,temp_uri,validator)
        end

        [uri,schema]
      end
    end
  end
end
