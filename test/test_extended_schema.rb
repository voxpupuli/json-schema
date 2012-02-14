require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class BitwiseAndAttribute < JSON::Schema::Attribute
  def self.validate(current_schema, data, fragments, validator, options = {})
    if data.is_a?(Integer) && data & current_schema.schema['bitwise-and'].to_i == 0
      message = "The property '#{build_fragment(fragments)}' did not evaluate  to true when bitwise-AND'd with  #{current_schema.schema['bitwise-or']}"
      raise JSON::Schema::ValidationError.new(message, fragments, self, current_schema)
    end
  end
end

class ExtendedSchema < JSON::Schema::Validator
  def initialize
    super
    extend_schema_definition("http://json-schema.org/draft-03/schema#")
    @attributes["bitwise-and"] = BitwiseAndAttribute
    @uri = URI.parse("http://test.com/test.json")
  end
  
  JSON::Validator.register_validator(self.new)
end

class JSONSchemaTestExtendedSchema < Test::Unit::TestCase
  def test_schema_from_file
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
    
    data = {"a" => 0, "b" => "taco"}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => 1, "b" => "taco"}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => 1, "b" => 5}
    assert(!JSON::Validator.validate(schema,data))
    
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
    
    data = {
      "a" => 0
    }
    
    data = {"a" => 1, "b" => "taco"}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => 0, "b" => "taco"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => 1, "b" => 5}
    assert(!JSON::Validator.validate(schema,data))
  end
end