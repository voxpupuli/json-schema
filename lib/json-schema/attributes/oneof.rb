require 'json-schema/attribute'

module JSON
  class Schema
    class OneOfAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        validation_errors = 0
        one_of = current_schema.schema['oneOf']

        one_of.each do |element|
          schema = JSON::Schema.new(element,current_schema.uri,validator)

          begin
            # need to raise exceptions on error because
            # schema.validate doesn't reliably return true/false
            schema.validate(data,fragments,processor,options.merge(:record_errors => false))
          rescue ValidationError
            validation_errors += 1
          end
        end

        return if validation_errors == one_of.length - 1

        if validation_errors == one_of.length
          message = "The property '#{build_fragment(fragments)}' of type #{data.class} did not match any of the required schemas"
        else
          message = "The property '#{build_fragment(fragments)}' of type #{data.class} matched more than one of the required schemas"
        end

        validation_error(processor, message, fragments, current_schema, self, options[:record_errors]) if message
      end
    end
  end
end
