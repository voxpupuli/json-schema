require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class JSONSchemaValidation < Test::Unit::TestCase
  def valid_schema
    {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => {
        "b" => {
          "required" => true
        }
      }
    }
  end

  def invalid_schema
    {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => {
        "b" => {
          "required" => "true"
        }
      }
    }
  end

  def test_draft03_validation
    data = {"b" => {"a" => 5}}
    assert(JSON::Validator.validate(valid_schema,data,:validate_schema => true))
    assert(!JSON::Validator.validate(invalid_schema,data,:validate_schema => true))
  end

  def test_validate_just_schema
    errors = JSON::Validator.fully_validate_schema(valid_schema)
    assert_equal [], errors

    errors = JSON::Validator.fully_validate_schema(invalid_schema)
    assert_equal 1, errors.size
    assert_match /the property .*required.*did not match/i, errors.first
  end
end
