require File.expand_path('../support/test_helper', __FILE__)

class ExtendedSchemaTest < Minitest::Test
  class BitwiseAndAttribute < JSON::Schema::Attribute
    def self.validate(current_schema, data, fragments, processor, validator, options = {})
      return unless data.is_a?(Integer)

      if data & current_schema.schema['bitwise-and'].to_i == 0
        message = "The property '#{build_fragment(fragments)}' did not evaluate to true when bitwise-AND'd with #{current_schema.schema['bitwise-and']}"
        validation_error(processor, message, fragments, current_schema, self, options[:record_errors])
      end
    end
  end

  class ExtendedSchema < JSON::Schema::Validator
    def initialize
      super
      extend_schema_definition("http://json-schema.org/draft-03/schema#")
      @attributes["bitwise-and"] = BitwiseAndAttribute
      @uri = Addressable::URI.parse("http://test.com/test.json")
    end

    JSON::Validator.register_validator(self.new)
  end

  def test_extended_schema_validation
    schema = {
      "$schema" => "http://test.com/test.json",
      "properties" => {
        "a" => {
          "bitwise-and" => 1
        },
        "b" => {
          "type" => "string"
        }
      }
    }

    assert_valid schema, {"a" => 1, "b" => "taco"}
    refute_valid schema, {"a" => 0, "b" => "taco"}
    refute_valid schema, {"a" => 1, "b" => 5}
  end

  def test_unextended_schema
    # Verify that using the original schema disregards the `bitwise-and` property
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {
          "bitwise-and" => 1
        },
        "b" => {
          "type" => "string"
        }
      }
    }

    assert_valid schema, {"a" => 0, "b" => "taco"}
    assert_valid schema, {"a" => 1, "b" => "taco"}
    refute_valid schema, {"a" => 1, "b" => 5}
  end
end
