module JSON
  class Schema
    class NotAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})

        schema = JSON::Schema.new(current_schema.schema['not'],current_schema.uri,validator)
        failed = true
        begin
          schema.validate(data,fragments,processor,options)
          message = "The property '#{build_fragment(fragments)}' of type #{data.class} matched the disallowed schema"
          failed = false
        rescue
          # Yay, we failed validation
        end

        unless failed
          validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
        end
      end
    end
  end
end