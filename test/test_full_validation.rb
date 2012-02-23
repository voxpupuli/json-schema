require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class JSONFullValidation < Test::Unit::TestCase
    
  def test_full_validation
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
  
  def test_full_validation_with_union_types
    data = {"b" => 5}
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => {
        "b" => {
          "type" => ["null","integer"]
        }
      }
    }
    
    errors = JSON::Validator.fully_validate(schema,data)
    assert(errors.empty?)
    
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => {
        "b" => {
          "type" => ["integer","null"]
        }
      }
    }
    
    errors = JSON::Validator.fully_validate(schema,data)
    assert(errors.empty?)
    
    data = {"b" => "a string"}
    
    errors = JSON::Validator.fully_validate(schema,data)
    assert(errors.length == 1)
   
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => {
        "b" => {
          "type" => [
            {
              "type" => "object",
              "properties" => {
                "c" => {"type" => "string"}
              }
            },
            {
              "type" => "object",
              "properties" => {
                "d" => {"type" => "integer"}
              }
            }
          ]
        }
      }
    }
    
    data = {"b" => {"c" => "taco"}}
    
    errors = JSON::Validator.fully_validate(schema,data)
    assert(errors.empty?)
    
    data = {"b" => {"d" => 6}}
    
    errors = JSON::Validator.fully_validate(schema,data)
    assert(errors.empty?)
    
    data = {"b" => {"c" => 6, "d" => "OH GOD"}}
    
    errors = JSON::Validator.fully_validate(schema,data)
    assert(errors.length == 1)
  end
  
  
  def test_full_validation_with_object_errors
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
    
    errors = JSON::Validator.fully_validate(schema,data,:errors_as_objects => true)
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

    errors = JSON::Validator.fully_validate(schema,data,:errors_as_objects => true)
    assert(errors.length == 2)
    assert(errors[0][:failed_attribute] == "Properties")
    assert(errors[0][:fragment] == "#/")
    assert(errors[1][:failed_attribute] == "Type")
    assert(errors[1][:fragment] == "#/c")
  end
  
  def test_full_validation_with_nested_required_properties
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => {
        "x" => {
          "required" => true,
          "type" => "object",
          "properties" => {
            "a" => {"type"=>"integer","required"=>true},
            "b" => {"type"=>"integer","required"=>true},
            "c" => {"type"=>"integer","required"=>false},
            "d" => {"type"=>"integer","required"=>false},
            "e" => {"type"=>"integer","required"=>false},
          }
        }
      }
    }
    data = {"x" => {"a"=>5, "d"=>5, "e"=>"what?"}}
    
    errors = JSON::Validator.fully_validate(schema,data,:errors_as_objects => true)
    assert_equal 2, errors.length
    assert_equal '#/x', errors[0][:fragment]
    assert_equal 'Properties', errors[0][:failed_attribute]
    assert_equal '#/x/e', errors[1][:fragment]
    assert_equal 'Type', errors[1][:failed_attribute]
  end
  
  def test_full_validation_with_nested_required_propertiesin_array
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => {
        "x" => {
          "required" => true,
          "type" => "array",
          "items" => {
            "type" => "object",
            "properties" => {
              "a" => {"type"=>"integer","required"=>true},
              "b" => {"type"=>"integer","required"=>true},
              "c" => {"type"=>"integer","required"=>false},
              "d" => {"type"=>"integer","required"=>false},
              "e" => {"type"=>"integer","required"=>false},
            }
          }
        }
      }
    }
    missing_b= {"a"=>5}
    e_is_wrong_type= {"a"=>5,"b"=>5,"e"=>"what?"}
    data = {"x" => [missing_b, e_is_wrong_type]}
    
    errors = JSON::Validator.fully_validate(schema,data,:errors_as_objects => true)
    assert_equal 2, errors.length
    assert_equal '#/x/0', errors[0][:fragment]
    assert_equal 'Properties', errors[0][:failed_attribute]
    assert_equal '#/x/1/e', errors[1][:fragment]
    assert_equal 'Type', errors[1][:failed_attribute]
  end
end
