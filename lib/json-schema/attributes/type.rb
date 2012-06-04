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
        
        # Create an array to hold errors that are generated during union validation
        union_errors = []
        
        types.each do |type|
          if type.is_a?(String)
            valid = data_valid_for_type?(data, type)
          elsif type.is_a?(Hash) && union
            # Validate as a schema
            schema = JSON::Schema.new(type,current_schema.uri,validator)
            
            # We're going to add a little cruft here to try and maintain any validation errors that occur in this union type
            # We'll handle this by keeping an error count before and after validation, extracting those errors and pushing them onto a union error
            pre_validation_error_count = validation_errors.count
            
            begin
              schema.validate(data,fragments,options)
              valid = true
            rescue ValidationError
              # We don't care that these schemas don't validate - we only care that one validated
            end
            
            diff = validation_errors.count - pre_validation_error_count
            valid = false if diff > 0
            while diff > 0
              diff = diff - 1
              union_errors.push(validation_errors.pop)
            end
          end

          break if valid
        end

        if (options[:disallow])
          if valid
            message = "The property '#{build_fragment(fragments)}' matched one or more of the following types:"
            types.each {|type| message += type.is_a?(String) ? " #{type}," : " (schema)," }
            message.chop!
            validation_error(message, fragments, current_schema, self, options[:record_errors])
          end
        elsif !valid
          if union
            message = "The property '#{build_fragment(fragments)}' of type #{data.class} did not match one or more of the following types:"
            types.each {|type| message += type.is_a?(String) ? " #{type}," : " (schema)," }
            message.chop!
            validation_error(message, fragments, current_schema, self, options[:record_errors])
            validation_errors.last.sub_errors = union_errors
          else
            message = "The property '#{build_fragment(fragments)}' of type #{data.class} did not match the following type:"
            types.each {|type| message += type.is_a?(String) ? " #{type}," : " (schema)," }
            message.chop!
            validation_error(message, fragments, current_schema, self, options[:record_errors])            
          end
        end
      end

      TYPE_CLASS_MAPPINGS = {
        "string" => String,
        "number" => Numeric,
        "integer" => Integer,
        "boolean" => [TrueClass, FalseClass],
        "object" => Hash,
        "array" => Array,
        "null" => NilClass,
        "any" => Object
      }

      def self.data_valid_for_type?(data, type)
        valid_classes = TYPE_CLASS_MAPPINGS.fetch(type) { return true }
        Array(valid_classes).any? { |c| data.is_a?(c) }
      end
    end
  end
end