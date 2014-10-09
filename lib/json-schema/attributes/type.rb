require 'json-schema/attribute'

module JSON
  class Schema
    class TypeAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
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
            pre_validation_error_count = validation_errors(processor).count

            begin
              schema.validate(data,fragments,processor,options)
              valid = true
            rescue ValidationError
              # We don't care that these schemas don't validate - we only care that one validated
            end

            diff = validation_errors(processor).count - pre_validation_error_count
            valid = false if diff > 0
            while diff > 0
              diff = diff - 1
              union_errors.push(validation_errors(processor).pop)
            end
          end

          break if valid
        end

        if (options[:disallow])
          if valid
            message = "The property '#{build_fragment(fragments)}' matched one or more of the following types:"
            types.each {|type| message += type.is_a?(String) ? " #{type}," : " (schema)," }
            message.chop!
            validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
          end
        elsif !valid
          if union
            message = "The property '#{build_fragment(fragments)}' of type #{type_of_data(data)} did not match one or more of the following types:"
            types.each {|type| message += type.is_a?(String) ? " #{type}," : " (schema)," }
            message.chop!
            validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
            validation_errors(processor).last.sub_errors = union_errors
          else
            message = "The property '#{build_fragment(fragments)}' of type #{type_of_data(data)} did not match the following type:"
            types.each {|type| message += type.is_a?(String) ? " #{type}," : " (schema)," }
            message.chop!
            validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end

      # Lookup Schema type of given class instance
      def self.type_of_data(data)
        type, klass = TYPE_CLASS_MAPPINGS.map { |k,v| [k,v] }.sort_by { |i|
          k,v = i
          -Array(v).map { |klass| klass.ancestors.size }.max
        }.find { |i|
          k,v = i
          Array(v).any? { |klass| data.kind_of?(klass) }
        }
        type
      end
    end
  end
end
