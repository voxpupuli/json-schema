require 'json-schema/attribute'

module JSON
  class Schema
    class TypeV4Attribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        union = true
        types = current_schema.schema['type']
        if !types.is_a?(Array)
          types = [types]
          union = false
        end
        valid = false

        # Create an array to hold errors that are generated during union validation
        union_errors = []

        types.each do |type|
          valid = data_valid_for_type?(data, type)
          break if valid
        end

        if !valid
          if union
            message = "The property '#{build_fragment(fragments)}' of type #{data.class} did not match one or more of the following types:"
            types.each {|type| message += type.is_a?(String) ? " #{type}," : " (schema)," }
            message.chop!
            validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
            validation_errors(processor).last.sub_errors = union_errors
          else
            message = "The property '#{build_fragment(fragments)}' of type #{data.class} did not match the following type:"
            types.each {|type| message += type.is_a?(String) ? " #{type}," : " (schema)," }
            message.chop!
            validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end
    end
  end
end
