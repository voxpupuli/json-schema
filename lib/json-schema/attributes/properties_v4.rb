require 'json-schema/attributes/properties'

module JSON
  class Schema
    class PropertiesV4Attribute < PropertiesAttribute
      # draft4 relies on its own RequiredAttribute validation at a higher level, rather than
      # as an attribute of individual properties.
      def self.required?(_schema, options)
        options[:allPropertiesRequired] == true
      end
    end
  end
end
