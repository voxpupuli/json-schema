module JSON
  class Schema
    class TypeAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        union = true

        if options[:disallow]
          types = current_schema.schema['disallow']
        else
          types = current_schema.schema['type']
        end

        if !types.is_a?(Array)
          types = [types]
          union = false
        end
        valid = false

        types.each do |type|
          if type.is_a?(String)
            case type
            when "string"
              valid = data.is_a?(String)
            when "number"
              valid = data.is_a?(Numeric)
            when "integer"
              valid = data.is_a?(Integer)
            when "boolean"
              valid = (data.is_a?(TrueClass) || data.is_a?(FalseClass))
            when "object"
              valid = data.is_a?(Hash)
            when "array"
              valid = data.is_a?(Array)
            when "null"
              valid = data.is_a?(NilClass)
            when "any"
              valid = true
            else
              valid = true
            end
          elsif type.is_a?(Hash) && union
            # Validate as a schema
            schema = JSON::Schema.new(type,current_schema.uri,validator)
            begin
              schema.validate(data,fragments)
              valid = true
            rescue ValidationError
              # We don't care that these schemas don't validate - we only care that one validated
            end
          end

          break if valid
        end

        if (options[:disallow])
          if valid
            message = "The property '#{build_fragment(fragments)}' matched one or more of the following types:"
            types.each {|type| message += type.is_a?(String) ? " #{type}," : " (schema)," }
            message.chop!
            validation_error(message, fragments, current_schema, options[:record_options])
          end
        elsif !valid
          message = "The property '#{build_fragment(fragments)}' did not match one or more of the following types:"
          types.each {|type| message += type.is_a?(String) ? " #{type}," : " (schema)," }
          message.chop!
          validation_error(message, fragments, current_schema, options[:record_options])
        end
      end
    end
  end
end