module JSON
  class Schema
    
    class Draft2 < Validator
      def initialize
        super
        @attributes = {
          "type" => JSON::Schema::TypeAttribute,
          "disallow" => JSON::Schema::DisallowAttribute,
          "format" => JSON::Schema::FormatAttribute,
          "maximum" => JSON::Schema::MaximumInclusiveAttribute,
          "minimum" => JSON::Schema::MinimumInclusiveAttribute,
          "minItems" => JSON::Schema::MinItemsAttribute,
          "maxItems" => JSON::Schema::MaxItemsAttribute,
          "uniqueItems" => JSON::Schema::UniqueItemsAttribute,
          "minLength" => JSON::Schema::MinLengthAttribute,
          "maxLength" => JSON::Schema::MaxLengthAttribute,
          "divisibleBy" => JSON::Schema::DivisibleByAttribute,
          "enum" => JSON::Schema::EnumAttribute,
          "properties" => JSON::Schema::PropertiesOptionalAttribute,
          "pattern" => JSON::Schema::PatternAttribute,
          "additionalProperties" => JSON::Schema::AdditionalPropertiesAttribute,
          "items" => JSON::Schema::ItemsAttribute,
          "extends" => JSON::Schema::ExtendsAttribute
        }
        @uri = URI.parse("http://json-schema.org/draft-02/schema#")
      end
      
      JSON::Validator.register_validator(self.new)
    end
    
  end
end