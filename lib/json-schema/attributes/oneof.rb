module JSON
  class Schema
    class OneOfAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        matched = false
        valid = false

        current_schema.schema['oneOf'].each do |element|
          schema = JSON::Schema.new(element,current_schema.uri,validator)

          begin
            schema.validate(data,fragments,processor,options)
            if matched
              valid = false
            else
              matched = true
              valid = true
            end
          rescue ValidationError
          end

        end

        if !valid
          if matched
            message = "The property '#{build_fragment(fragments)}' of type #{data.class} matched more than one of the required schemas"
          else
            message = "The property '#{build_fragment(fragments)}' of type #{data.class} did not match any of the required schemas"
          end
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
          validation_errors(processor).last.sub_errors = errors
        end
      end
    end
  end
end