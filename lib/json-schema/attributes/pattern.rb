module JSON
  class Schema
    class PatternAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if data.is_a?(String)
          r = Regexp.new(current_schema.schema['pattern'])
          if (r.match(data)).nil?
            message = "The property '#{build_fragment(fragments)}' did not match the regex '#{current_schema.schema['pattern']}'"
            validation_error(message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end
    end
  end
end