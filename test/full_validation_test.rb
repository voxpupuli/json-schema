require File.expand_path('../support/test_helper', __FILE__)

class FullValidationTest < Minitest::Test

  def test_full_validation
    data = {"b" => {"a" => 5}}
    schema = {
      "type" => "object",
      "required" => ["b"],
      "properties" => {
        "b" => {
        }
      }
    }

    errors = JSON::Validator.fully_validate(schema,data)
    assert(errors.empty?)

    data = {"c" => 5}
    schema = {
      "type" => "object",
      "required" => ["b"],
      "properties" => {
        "b" => {
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
      "type" => "object",
      "required" => ["b"],
      "properties" => {
        "b" => {
        }
      }
    }

    errors = JSON::Validator.fully_validate(schema,data,:errors_as_objects => true)
    assert(errors.empty?)

    data = {"c" => 5}
    schema = {
      "type" => "object",
      "required" => ["b"],
      "properties" => {
        "b" => {
        },
        "c" => {
          "type" => "string"
        }
      }
    }

    errors = JSON::Validator.fully_validate(schema,data,:errors_as_objects => true)

    assert_equal errors.length, 2
    assert_equal errors[0][:failed_attribute], "Required"
    assert_equal errors[0][:fragment], "#/"
    assert_equal errors[0][:property_fragment], "#/b"
    assert_equal errors[1][:failed_attribute], "TypeV4"
    assert_equal errors[1][:fragment], "#/c"
    assert_equal errors[1][:property_fragment], "#/c"
  end

  def test_full_validation_with_nested_required_properties
    schema = {
      "type" => "object",
      "required" => ["x"],
      "properties" => {
        "x" => {
          "type" => "object",
          "required" => ["a", "b"],
          "properties" => {
            "a" => {"type"=>"integer"},
            "b" => {"type"=>"integer"},
            "c" => {"type"=>"integer"},
            "d" => {"type"=>"integer"},
            "e" => {"type"=>"integer"},
          }
        }
      }
    }
    data = {"x" => {"a"=>5, "d"=>5, "e"=>"what?"}}

    errors = JSON::Validator.fully_validate(schema,data,:errors_as_objects => true)
    assert_equal 2, errors.length
    assert_equal '#/x', errors[0][:fragment]
    assert_equal '#/x/b', errors[0][:property_fragment]
    assert_equal 'Required', errors[0][:failed_attribute]
    assert_equal '#/x/e', errors[1][:fragment]
    assert_equal '#/x/e', errors[1][:property_fragment]
    assert_equal 'TypeV4', errors[1][:failed_attribute]
  end

  def test_full_validation_with_nested_required_propertiesin_array
    schema = {
      "type" => "object",
      "required" => ["x"],
      "properties" => {
        "x" => {
          "type" => "array",
          "items" => {
            "type" => "object",
            "required" => ["a", "b"],
            "properties" => {
              "a" => {"type"=>"integer"},
              "b" => {"type"=>"integer"},
              "c" => {"type"=>"integer"},
              "d" => {"type"=>"integer"},
              "e" => {"type"=>"integer"},
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
    assert_equal '#/x/0/b', errors[0][:property_fragment]
    assert_equal 'Required', errors[0][:failed_attribute]
    assert_equal '#/x/1/e', errors[1][:fragment]
    assert_equal '#/x/1/e', errors[1][:property_fragment]
    assert_equal 'TypeV4', errors[1][:failed_attribute]
  end
end
