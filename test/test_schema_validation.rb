require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class JSONSchemaValidation < Test::Unit::TestCase
  def valid_schema_v3
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

  def invalid_schema_v3
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

  def valid_schema_v4
    {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "required" => ["b"],
      "properties" => {
      }
    }
  end

  def invalid_schema_v4
    {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "required" => "b",
      "properties" => {
      }
    }
  end

  def test_draft03_validation
    data = {"b" => {"a" => 5}}
    assert(JSON::Validator.validate(valid_schema_v3,data,:validate_schema => true, :version => :draft3))
    assert(!JSON::Validator.validate(invalid_schema_v3,data,:validate_schema => true, :version => :draft3))
  end

  def test_validate_just_schema_draft03
    errors = JSON::Validator.fully_validate_schema(valid_schema_v3, :version => :draft3)
    assert_equal [], errors

    errors = JSON::Validator.fully_validate_schema(invalid_schema_v3, :version => :draft3)
    assert_equal 1, errors.size
    assert_match /the property .*required.*did not match/i, errors.first
  end


  def test_draft04_validation
    data = {"b" => {"a" => 5}}
    assert(JSON::Validator.validate(valid_schema_v4,data,:validate_schema => true, :version => :draft4))
    assert(!JSON::Validator.validate(invalid_schema_v4,data,:validate_schema => true, :version => :draft4))
  end

  def test_validate_just_schema_draft04
    errors = JSON::Validator.fully_validate_schema(valid_schema_v4, :version => :draft4)
    assert_equal [], errors

    errors = JSON::Validator.fully_validate_schema(invalid_schema_v4, :version => :draft4)
    assert_equal 1, errors.size
    assert_match /the property .*required.*did not match/i, errors.first
  end

  def test_validate_schema_3_without_version_option
    data = {"b" => {"a" => 5}}
    assert(JSON::Validator.validate(valid_schema_v3,data,:validate_schema => true))
    assert(!JSON::Validator.validate(invalid_schema_v3,data,:validate_schema => true))
  end
end
