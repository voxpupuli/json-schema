require 'json-schema/attribute'

module JSON
  class Schema
    class OneOfAttribute < Attribute
      def self.validate(current_schema, data, fragments, processor, validator, options = {})
        validation_errors = 0
        current_schema.schema['oneOf'].each do |element|
          schema = JSON::Schema.new(element,current_schema.uri,validator)

          begin
            # need to raise exceptions on error because
            # schema.validate doesn't reliably return true/false
            schema.validate(data,fragments,processor,options.merge(:record_errors => false))
          rescue ValidationError
            validation_errors += 1
          end

        end

        case validation_errors
        when current_schema.schema['oneOf'].length - 1 # correct, matched only one
          message = nil
        when current_schema.schema['oneOf'].length  # didn't match any
          message = "The property '#{build_fragment(fragments)}' of type #{data.class} did not match any of the required schemas"
        else # too many matches
          message = "The property '#{build_fragment(fragments)}' of type #{data.class} matched more than one of the required schemas"
        end

        validation_error(processor, message, fragments, current_schema, self, options[:record_errors]) if message
      end
    end
  end
end
