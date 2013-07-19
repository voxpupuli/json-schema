require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class RubySchemaTest < Test::Unit::TestCase
  def test_string_keys
    schema = {
      "type" => 'object',
      "required" => ["a"],
      "properties" => {
        "a" => {"type" => "integer", "default" => 42},
        "b" => {"type" => "integer"}
      }
    }

    data = {
      "a" => 5
    }

    assert(JSON::Validator.validate(schema, data))
  end

  def test_symbol_keys
    schema = {
      type: 'object',
      required: ["a"],
      properties: {
        a: {type: "integer", default: 42},
        b: {type: "integer"}
      }
    }

    data = {
      a: 5
    }

    assert(JSON::Validator.validate(schema, data))
  end
end