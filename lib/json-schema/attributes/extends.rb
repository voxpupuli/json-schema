module JSON
  class Schema
    class ExtendsAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        schemas = current_schema.schema['extends']
        schemas = [schemas] if !schemas.is_a?(Array)
        schemas.each do |s|
          if s.is_a?(Hash)
            schema = JSON::Schema.new(s,current_schema.uri,validator)
            schema.validate(data, fragments, options)
          elsif s.is_a?(String)
            temp_uri = URI.parse(s)
            if temp_uri.relative?
              temp_uri = current_schema.uri.clone
              # Check for absolute path
              path = s.split("#")[0]
              if path.nil? || path == ''
                temp_uri.path = current_schema.uri.path
              elsif path[0,1] == "/"
                temp_uri.path = Pathname.new(path).cleanpath.to_s
              else
                temp_uri = current_schema.uri.merge(path)
              end
              temp_uri.fragment = s.split("#")[1]
            end
            temp_uri.fragment = "" if temp_uri.fragment.nil?

            # Grab the parent schema from the schema list
            schema_key = temp_uri.to_s.split("#")[0] + "#"

            ref_schema = JSON::Validator.schemas[schema_key]

            if ref_schema
              # Perform fragment resolution to retrieve the appropriate level for the schema
              target_schema = ref_schema.schema
              fragments = temp_uri.fragment.split("/")
              fragment_path = ''
              fragments.each do |fragment|
                if fragment && fragment != ''
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
              schema = JSON::Schema.new(target_schema,temp_uri,validator)
              schema.validate(data, fragments, options)
            else
              message = "The extended schema '#{temp_uri.to_s}' cannot be found"
              validation_error(message, fragments, current_schema, self, options[:record_errors])
            end
          else
            message = "The property '#{build_fragment(fragments)}' was not a valid schema"
            validation_error(message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end
    end
  end
end