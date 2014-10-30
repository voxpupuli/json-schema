# encoding: utf-8
require File.expand_path('../test_helper', __FILE__)

class JSONSchemaDraft4Test < MiniTest::Unit::TestCase
  def schema_version
    :draft4
  end

  def exclusive_minimum
    { 'exclusiveMinimum' => true }
  end

  def exclusive_maximum
    { 'exclusiveMaximum' => true }
  end

  include TypeValidationTests
  include ArrayPropertyValidationTests
  include ArrayUniqueItemsValidationTests
  include ArrayAdditionalItemsValidationTests
  include NumberPropertyValidationTests
  include ObjectAdditionalPropertyValidationTests
  include ObjectPatternPropertyValidationTests
  include StringPropertyValidationTests

  def test_required
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "required" => ["a"],
      "properties" => {
        "a" => {}
      }
    }
    data = {}

    refute_valid schema, data
    data['a'] = "Hello"
    assert_valid schema, data

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"type" => "integer"}
      }
    }

    data = {}
    assert_valid schema, data
  end

  def test_min_properties
    schema = { 'minProperties' => 2 }

    assert_valid schema, {'a' => 1, 'b' => 2}
    assert_valid schema, {'a' => 1, 'b' => 2, 'c' => 3}

    refute_valid schema, {'a' => 1}
    refute_valid schema, {}
  end

  def test_max_properties
    schema = { 'maxProperties' => 2 }

    assert_valid schema, {'a' => 1, 'b' => 2}
    assert_valid schema, {'a' => 1}
    assert_valid schema, {}

    refute_valid schema, {'a' => 1, 'b' => 2, 'c' => 3}
  end

  def test_strict_properties
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"type" => "string"},
        "b" => {"type" => "string"}
      }
    }

    data = {"a" => "a"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"b" => "b"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b"}
    assert(JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b", "c" => "c"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))
  end

  def test_strict_properties_additional_props
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"type" => "string"},
        "b" => {"type" => "string"}
      },
      "additionalProperties" => {"type" => "integer"}
    }

    data = {"a" => "a"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"b" => "b"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b"}
    assert(JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b", "c" => "c"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b", "c" => 3}
    assert(JSON::Validator.validate(schema,data,:strict => true))
  end

  def test_strict_properties_pattern_props
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {"type" => "string"},
        "b" => {"type" => "string"}
      },
      "patternProperties" => {"\\d+ taco" => {"type" => "integer"}}
    }

    data = {"a" => "a"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"b" => "b"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b"}
    assert(JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b", "c" => "c"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b", "c" => 3}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b", "23 taco" => 3}
    assert(JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b", "23 taco" => "cheese"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))
  end

  def test_enum
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"enum" => [1,'boo',[1,2,3],{"a" => "b"}]}
      }
    }

    data = {
      "a" => nil
    }

    # Make sure all of the above are valid...
    data["a"] = 1
    assert_valid schema, data

    data["a"] = 'boo'
    assert_valid schema, data

    data["a"] = [1,2,3]
    assert_valid schema, data

    data["a"] = {"a" => "b"}
    assert_valid schema, data

    # Test something that doesn't exist
    data["a"] = 'taco'
    refute_valid schema, data

    # Try it without the key
    data = {}
    assert_valid schema, data
  end

  def test_enum_with_schema_validation
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"enum" => [1,'boo',[1,2,3],{"a" => "b"}]}
      }
    }

    data = {
      "a" => nil
    }

    # Make sure all of the above are valid...
    data["a"] = 1
    assert(JSON::Validator.validate(schema,data,:validate_schema => true))
  end


  def test_multiple_of
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"multipleOf" => 1.1}
      }
    }

    data = {
      "a" => nil
    }

    data["a"] = 3.3
    assert_valid schema, data

    data["a"] = 3.4
    refute_valid schema, data

    schema["properties"]["a"]["multipleOf"] = 2.0

    data["a"] = 4.0
    assert_valid schema, data

    data["a"] = 'boo'
    assert_valid schema, data

    data["a"] = 5
    schema["properties"]["a"]["multipleOf"] = 0
    refute_valid schema, data
  end

  def test_list_option
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "required" => ["a"],
      "properties" => { "a" => {"type" => "integer"} }
    }

    data = [{"a" => 1},{"a" => 2},{"a" => 3}]
    assert(JSON::Validator.validate(schema,data,:list => true))
    refute_valid schema, data

    data = {"a" => 1}
    assert(!JSON::Validator.validate(schema,data,:list => true))

    data = [{"a" => 1},{"b" => 2},{"a" => 3}]
    assert(!JSON::Validator.validate(schema,data,:list => true))
  end


  def test_self_reference
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "integer"}, "b" => {"$ref" => "#"}}
    }

    assert_valid schema, {"a" => 5, "b" => {"b" => {"a" => 1}}}
    refute_valid schema, {"a" => 5, "b" => {"b" => {"a" => 'taco'}}}
  end


  def test_format_ipv4
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "ipv4"}}
    }

    assert_valid schema, {"a" => "1.1.1.1"}
    refute_valid schema, {"a" => "1.1.1"}
    refute_valid schema, {"a" => "1.1.1.300"}
    refute_valid schema, {"a" => 5}
    refute_valid schema, {"a" => "1.1.1"}
    refute_valid schema, {"a" => "1.1.1.1b"}
  end


  def test_format_ipv6
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "ipv6"}}
    }

    assert_valid schema, {"a" => "1111:2222:8888:9999:aaaa:cccc:eeee:ffff"}
    assert_valid schema, {"a" => "1111:0:8888:0:0:0:eeee:ffff"}
    assert_valid schema, {"a" => "1111:2222:8888::eeee:ffff"}
    refute_valid schema, {"a" => "1111:2222:8888:99999:aaaa:cccc:eeee:ffff"}
    refute_valid schema, {"a" => "1111:2222:8888:9999:aaaa:cccc:eeee:gggg"}
    refute_valid schema, {"a" => "1111:2222::9999::cccc:eeee:ffff"}
    refute_valid schema, {"a" => "1111:2222:8888:9999:aaaa:cccc:eeee:ffff:bbbb"}
    assert(JSON::Validator.validate(schema, {"a" => "::1"}), 'validate with shortcut')
    assert(!JSON::Validator.validate(schema, {"a" => "42"}), 'not validate a simple number')
  end


  def test_format_datetime
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "date-time"}}
    }

    assert_valid schema, {"a" => "2010-01-01T12:00:00Z"}
    assert_valid schema, {"a" => "2010-01-01T12:00:00.1Z"}
    refute_valid schema, {"a" => "2010-01-01T12:00:00,1Z"}
    refute_valid schema, {"a" => "2010-01-01T12:00:00+0000"}
    assert_valid schema, {"a" => "2010-01-01T12:00:00+00:00"}
    refute_valid schema, {"a" => "2010-01-32T12:00:00Z"}
    refute_valid schema, {"a" => "2010-13-01T12:00:00Z"}
    assert_valid schema, {"a" => "2010-01-01T24:00:00Z"}
    refute_valid schema, {"a" => "2010-01-01T12:60:00Z"}
    assert_valid schema, {"a" => "2010-01-01T12:00:60Z"}
    assert_valid schema, {"a" => "2010-01-01T12:00:00z"}
    refute_valid schema, {"a" => "2010-01-0112:00:00Z"}
  end

  def test_format_uri
    data1 = {"a" => "http://gitbuh.com"}
    data2 = {"a" => "::boo"}
    data3 = {"a" => "http://ja.wikipedia.org/wiki/メインページ"}

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "uri"}}
    }

    assert(JSON::Validator.validate(schema,data1))
    assert(!JSON::Validator.validate(schema,data2))
    assert(JSON::Validator.validate(schema,data3))
  end

  def test_format_unknown
    schema = {
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "unknown"}}
    }

    assert_valid schema, {"a" => "I can write what I want here"}
    assert_valid schema, {"a" => ""}
  end


  def test_format_union
    data1 = {"a" => "boo"}
    data2 = {"a" => nil}

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => ["string","null"], "format" => "ipv4"}}
    }
    assert(!JSON::Validator.validate(schema,data1))
    assert(JSON::Validator.validate(schema,data2))
  end



  def test_schema
    schema = {
      "$schema" => "http://json-schema.org/THIS-IS-NOT-A-SCHEMA",
      "type" => "object"
    }

    data = {"a" => "taco"}
    assert(!JSON::Validator.validate(schema,data))

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object"
    }
    assert_valid schema, data
  end

  def test_dependency
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => {
        "a" => {"type" => "integer"},
        "b" => {"type" => "integer"}
      },
      "dependencies" => {
        "a" => ["b"]
      }
    }

    data = {"a" => 1, "b" => 2}
    assert_valid schema, data
    data = {"a" => 1}
    refute_valid schema, data

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => {
        "a" => {"type" => "integer"},
        "b" => {"type" => "integer"},
        "c" => {"type" => "integer"}
      },
      "dependencies" => {
        "a" => ["b","c"]
      }
    }

    data = {"a" => 1, "c" => 2}
    refute_valid schema, data
    data = {"a" => 1, "b" => 2, "c" => 3}
    assert_valid schema, data
  end

  def test_schema_dependency
    schema = {
      "type"=> "object",
      "properties"=> {
        "name"=> { "type"=> "string" },
        "credit_card"=> { "type"=> "number" }
      },
      "required"=> ["name"],
      "dependencies"=> {
        "credit_card"=> {
          "properties"=> {
            "billing_address"=> { "type"=> "string" }
          },
          "required"=> ["billing_address"]
        }
      }
    }
    data = {
      "name" => "John Doe",
      "credit_card" => 5555555555555555
    }
    assert(!JSON::Validator.validate(schema,data), 'test schema dependency with invalid data')
    data['billing_address'] = "Somewhere over the rainbow"
    assert(JSON::Validator.validate(schema,data), 'test schema dependency with valid data')
  end

  def test_default
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => {
        "a" => {"type" => "integer", "default" => 42},
        "b" => {"type" => "integer"}
      }
    }

    data = {:b => 2}
    assert_valid schema, data
    assert_nil(data["a"])
    assert(JSON::Validator.validate(schema,data, :insert_defaults => true))
    assert_equal(42, data["a"])
    assert_equal(2, data[:b])

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "required" => ["a"],
      "properties" => {
        "a" => {"type" => "integer", "default" => 42},
        "b" => {"type" => "integer"}
      }
    }

    data = {:b => 2}
    refute_valid schema, data
    assert_nil(data["a"])
    assert(JSON::Validator.validate(schema,data, :insert_defaults => true))
    assert_equal(42, data["a"])
    assert_equal(2, data[:b])

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "required" => ["a"],
      "properties" => {
        "a" => {"type" => "integer", "default" => 42, "readonly" => true},
        "b" => {"type" => "integer"}
      }
    }

    data = {:b => 2}
    refute_valid schema, data
    assert_nil(data["a"])
    assert(!JSON::Validator.validate(schema,data, :insert_defaults => true))
    assert_nil(data["a"])
    assert_equal(2, data[:b])

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => {
        "a" => {"type" => "integer", "default" => "42"},
        "b" => {"type" => "integer"}
      }
    }

    data = {:b => 2}
    assert_valid schema, data
    assert_nil(data["a"])
    assert(!JSON::Validator.validate(schema,data, :insert_defaults => true))
    assert_equal("42",data["a"])
    assert_equal(2, data[:b])

  end


  def test_all_of
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "allOf" => [
        {
          "properties" => {"a" => {"type" => "string"}},
          "required" => ["a"]
        },
        {
          "properties" => {"b" => {"type" => "integer"}}
        }
      ]
    }

    data = {"a" => "hello", "b" => 5}
    assert_valid schema, data

    data = {"a" => "hello"}
    assert_valid schema, data

    data = {"a" => "hello", "b" => "taco"}
    refute_valid schema, data

    data = {"b" => 5}
    refute_valid schema, data
  end


  def test_any_of
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "anyOf" => [
        {
          "properties" => {"a" => {"type" => "string"}},
          "required" => ["a"]
        },
        {
          "properties" => {"b" => {"type" => "integer"}}
        }
      ]
    }

    data = {"a" => "hello", "b" => 5}
    assert_valid schema, data

    data = {"a" => "hello"}
    assert_valid schema, data

    data = {"a" => "hello", "b" => "taco"}
    assert_valid schema, data

    data = {"b" => 5}
    assert_valid schema, data

    data = {"a" => 5, "b" => "taco"}
    refute_valid schema, data
  end


  def test_one_of
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "oneOf" => [
        {
          "properties" => {"a" => {"type" => "string"}},
          "required" => ["a"]
        },
        {
          "properties" => {"b" => {"type" => "integer"}}
        }
      ]
    }

    data = {"a" => "hello", "b" => 5}
    refute_valid schema, data

    # This passes because b is not required, thus matches both schemas
    data = {"a" => "hello"}
    refute_valid schema, data

    data = {"a" => "hello", "b" => "taco"}
    assert_valid schema, data

    data = {"b" => 5}
    assert_valid schema, data

    data = {"a" => 5, "b" => "taco"}
    refute_valid schema, data
  end


  def test_not
    # Start with a simple not
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"not" => { "type" => ["string", "boolean"]}}
      }
    }

    data = {"a" => 1}
    assert_valid schema, data

    data = {"a" => "hi!"}
    refute_valid schema, data

    data = {"a" => true}
    refute_valid schema, data

    # Sub-schema not
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"not" => {"anyOf" => [
            {
              "type" => ["string","boolean"]
            },
            {
              "type" => "object",
              "properties" => {
                "b" => {"type" => "boolean"}
              }
            }
          ]}
        }
      }
    }

    data = {"a" => 1}
    assert_valid schema, data

    data = {"a" => "hi!"}
    refute_valid schema, data

    data = {"a" => true}
    refute_valid schema, data

    data = {"a" => {"b" => true}}
    refute_valid schema, data

    data = {"a" => {"b" => 5}}
    assert_valid schema, data
  end

  def test_not_fully_validate
    # Start with a simple not
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"not" => { "type" => ["string", "boolean"]}}
      }
    }

    data = {"a" => 1}
    errors = JSON::Validator.fully_validate(schema,data)
    assert_equal(0, errors.length)

    data = {"a" => "taco"}
    errors = JSON::Validator.fully_validate(schema,data)
    assert_equal(1, errors.length)
  end

  def test_definitions
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "array",
      "items" => { "$ref" => "#/definitions/positiveInteger"},
      "definitions" => {
        "positiveInteger" => {
          "type" => "integer",
          "minimum" => 0,
          "exclusiveMinimum" => true
        }
      }
    }

    data = [1,2,3]
    assert_valid schema, data

    data = [-1,2,3]
    refute_valid schema, data
  end
end


