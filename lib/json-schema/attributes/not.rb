module JSON
  class Schema
    class NotAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})

        schema = JSON::Schema.new(current_schema.schema['allOf'],current_schema.uri,validator)

        begin
          schema.validate(data,fragments,processor,options)
          message = "The property '#{build_fragment(fragments)}' of type #{data.class} matched the disallowed schema"
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        rescue
          # Yay, we failed validation
        end
      end
    end
  end
end