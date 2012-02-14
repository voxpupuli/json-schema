module JSON
  class Schema
    class UniqueItemsAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if data.is_a?(Array)
          d = data.clone
          dupes = d.uniq!
          if dupes
            message = "The property '#{build_fragment(fragments)}' contained duplicated array values"
            validation_error(message, fragments, current_schema, self, options[:record_errors])
          end
        end
      end
    end
  end
end