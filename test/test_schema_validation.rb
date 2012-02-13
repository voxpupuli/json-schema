require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class JSONSchemaValidation < Test::Unit::TestCase
    
  def test_draft03_validation
    data = {"b" => {"a" => 5}}
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => {
        "b" => {
          "required" => true
        }
      }
    }
    
    assert(JSON::Validator.validate(schema,data,:validate_schema => true))
  
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => {
        "b" => {
          "required" => "true"
        }
      }
    }     
    assert(!JSON::Validator.validate(schema,data,:validate_schema => true))
  end
end
