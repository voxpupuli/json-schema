module JSON
  class Schema
    class DisallowAttribute < Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
        if validator.attributes['type']
          validator.attributes['type'].validate(current_schema, data, fragments, validator, {:disallow => true}.merge(options))
        end
      end
    end
  end
end