require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class JSONFullValidation < Test::Unit::TestCase
    
  def test_full_validation
    if JSON::Validator.json_backend != nil
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
      
      errors = JSON::Validator.fully_validate(schema,data)
      assert(errors.empty?)

      data = {"c" => 5}
      schema = {
        "$schema" => "http://json-schema.org/draft-03/schema#",
        "type" => "object",
        "properties" => {
          "b" => {
            "required" => true
          },
          "c" => {
            "type" => "string"
          }
        }
      }

      errors = JSON::Validator.fully_validate(schema,data)
      assert(errors.length == 2)
    end
  end
end