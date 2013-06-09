module JSON
  class Schema

    class Draft4 < Validator
      def initialize
        super
        @attributes = {
          "type" => JSON::Schema::TypeV4Attribute,
          "allOf" => JSON::Schema::AllOfAttribute,
          "anyOf" => JSON::Schema::AnyOfAttribute,
          "oneOf" => JSON::Schema::OneOfAttribute,
          "not" => JSON::Schema::NotAttribute,
          "disallow" => JSON::Schema::DisallowAttribute,
          "format" => JSON::Schema::FormatAttribute,
          "maximum" => JSON::Schema::MaximumAttribute,
          "minimum" => JSON::Schema::MinimumAttribute,
          "minItems" => JSON::Schema::MinItemsAttribute,
          "maxItems" => JSON::Schema::MaxItemsAttribute,
          "minProperties" => JSON::Schema::MinPropertiesAttribute,
          "maxProperties" => JSON::Schema::MaxPropertiesAttribute,
          "uniqueItems" => JSON::Schema::UniqueItemsAttribute,
          "minLength" => JSON::Schema::MinLengthAttribute,
          "maxLength" => JSON::Schema::MaxLengthAttribute,
          "multipleOf" => JSON::Schema::DivisibleByAttribute,
          "enum" => JSON::Schema::EnumAttribute,
          "properties" => JSON::Schema::PropertiesV4Attribute,
          "required" => JSON::Schema::RequiredAttribute,
          "pattern" => JSON::Schema::PatternAttribute,
          "patternProperties" => JSON::Schema::PatternPropertiesAttribute,
          "additionalProperties" => JSON::Schema::AdditionalPropertiesAttribute,
          "items" => JSON::Schema::ItemsAttribute,
          "additionalItems" => JSON::Schema::AdditionalItemsAttribute,
          "dependencies" => JSON::Schema::DependenciesV4Attribute,
          "extends" => JSON::Schema::ExtendsAttribute,
          "$ref" => JSON::Schema::RefAttribute
        }
        @uri = URI.parse("http://json-schema.org/draft-04/schema#")
      end

      JSON::Validator.register_validator(self.new)
      JSON::Validator.register_default_validator(self.new)
    end

  end
end