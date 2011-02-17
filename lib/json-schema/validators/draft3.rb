module JSON
  class Schema
    
    class Draft3 < Validator
      def initialize
        super
        @attributes = {
          "type" => JSON::Schema::TypeAttribute,
          "disallow" => JSON::Schema::DisallowAttribute,
          "format" => JSON::Schema::FormatAttribute,
          "maximum" => JSON::Schema::MaximumAttribute,
          "minimum" => JSON::Schema::MinimumAttribute,
          "minItems" => JSON::Schema::MinItemsAttribute,
          "maxItems" => JSON::Schema::MaxItemsAttribute,
          "uniqueItems" => JSON::Schema::UniqueItemsAttribute,
          "minLength" => JSON::Schema::MinLengthAttribute,
          "maxLength" => JSON::Schema::MaxLengthAttribute,
          "divisibleBy" => JSON::Schema::DivisibleByAttribute,
          "enum" => JSON::Schema::EnumAttribute,
          "properties" => JSON::Schema::PropertiesAttribute,
          "pattern" => JSON::Schema::PatternAttribute,
          "patternProperties" => JSON::Schema::PatternPropertiesAttribute,
          "additionalProperties" => JSON::Schema::AdditionalPropertiesAttribute,
          "items" => JSON::Schema::ItemsAttribute,
          "additionalItems" => JSON::Schema::AdditionalItemsAttribute,
          "dependencies" => JSON::Schema::DependenciesAttribute,
          "extends" => JSON::Schema::ExtendsAttribute,
          "$ref" => JSON::Schema::RefAttribute
        }
        @uri = URI.parse("http://json-schema.org/draft-03/schema#")
      end
      
      JSON::Validator.register_validator(self.new)
      JSON::Validator.register_default_validator(self.new)
    end
    
  end
end