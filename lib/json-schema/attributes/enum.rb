module JSON
  class Schema
    class EnumAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if !current_schema.schema['enum'].include?(data)
          message = "The property '#{build_fragment(fragments)}' did not match one of the following values:"
          current_schema.schema['enum'].each {|val|
            if val.is_a?(NilClass)
              message += " null,"
            elsif val.is_a?(Array)
              message += " (array),"
            elsif val.is_a?(Hash)
              message += " (object),"
            else
              message += " #{val.to_s},"
            end
          }
          message.chop!
          raise ValidationError.new(message, fragments, current_schema)
        end
      end
    end
  end
end