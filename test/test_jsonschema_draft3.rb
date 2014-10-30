# encoding: utf-8
require File.expand_path('../test_helper', __FILE__)

class JSONSchemaDraft3Test < MiniTest::Unit::TestCase
  def test_types
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {}
      }
    }
    data = {
      "a" => nil
    }

    # Test an array of unioned-type objects that prevent additionalProperties
    schema["properties"]["a"] = {
      'type' => 'array',
      'items' => {
        'type' => [
          { 'type' => 'object', 'properties' => { "b" => { "type" => "integer" } } },
          { 'type' => 'object', 'properties' => { "c" => { "type" => "string" } } }
        ],
        'additionalProperties' => false
      }
    }

    data["a"] = [{"b" => 5}, {"c" => "foo"}]
    errors = JSON::Validator.fully_validate(schema, data)
    assert(errors.empty?, errors.join("\n"))

    # This should actually pass, because this matches the first schema in the union
    data["a"] << {"c" => false}
    assert_valid schema, data
  end

  def test_required
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {"required" => true}
      }
    }
    data = {}

    refute_valid schema, data
    data['a'] = "Hello"
    assert_valid schema, data

    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {"type" => "integer"}
      }
    }

    data = {}
    assert_valid schema, data
  end


  def test_min_items
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {"minItems" => 1}
      }
    }

    data = {
      "a" => nil
    }

    # Test with an array
    data["a"] = ["boo"]
    assert_valid schema, data

    data["a"] = []
    refute_valid schema, data

    # Test with a non-array
    data["a"] = "boo"
    assert_valid schema, data
  end



  def test_max_items
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {"maxItems" => 1}
      }
    }

    data = {
      "a" => nil
    }

    # Test with an array
    data["a"] = ["boo"]
    assert_valid schema, data

    data["a"] = ["boo","taco"]
    refute_valid schema, data

    # Test with a non-array
    data["a"] = "boo"
    assert_valid schema, data
  end



  def test_unique_items
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {"uniqueItems" => true}
      }
    }

    data = {
      "a" => nil
    }

    # Test with nulls
    data["a"] = [nil,5]
    assert_valid schema, data

    data["a"] = [nil,nil]
    refute_valid schema, data

    # Test with booleans
    data["a"] = [true,4]
    assert_valid schema, data

    data["a"] = [true,false]
    assert_valid schema, data

    data["a"] = [true,true]
    refute_valid schema, data

    # Test with numbers
    data["a"] = [4,true]
    assert_valid schema, data

    data["a"] = [4,4.1]
    assert_valid schema, data

    data["a"] = [4,4]
    refute_valid schema, data

    # Test with strings
    data["a"] = ['a',true]
    assert_valid schema, data

    data["a"] = ['a','ab']
    assert_valid schema, data

    data["a"] = ['a','a']
    refute_valid schema, data

    # Test with arrays
    data["a"] = [[1],true]
    assert_valid schema, data

    data["a"] = [[1,2],[1,3]]
    assert_valid schema, data

    data["a"] = [[1,2,3],[1,2,3]]
    refute_valid schema, data

    # Test with objects
    data["a"] = [{"a" => 1},true]
    assert_valid schema, data

    data["a"] = [{"a" => 1},{"a" => 2}]
    assert_valid schema, data

    data["a"] = [{"a" => 1, "b" => 2}, {"a" => 1, "b" => 2}]
    refute_valid schema, data
  end

  def test_strict_properties
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
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

  def test_strict_properties_required_props
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {"type" => "string", "required" => true},
        "b" => {"type" => "string", "required" => false}
      }
    }

    data = {"a" => "a"}
    assert(JSON::Validator.validate(schema,data,:strict => true))

    data = {"b" => "b"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b"}
    assert(JSON::Validator.validate(schema,data,:strict => true))
  end

  def test_strict_properties_additional_props
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
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

  def test_pattern
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {"pattern" => "\\d+ taco"}
      }
    }

    data = {
      "a" => nil
    }

    # Test strings
    data["a"] = "156 taco bell"
    assert_valid schema, data

    # Test a non-string
    data["a"] = 5
    assert_valid schema, data

    data["a"] = "taco"
    refute_valid schema, data
  end


  def test_min_length
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {"minLength" => 1}
      }
    }

    data = {
      "a" => nil
    }

    # Try out strings
    data["a"] = "t"
    assert_valid schema, data

    data["a"] = ""
    refute_valid schema, data

    # Try out non-string
    data["a"] = 5
    assert_valid schema, data
  end


  def test_max_length
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {"maxLength" => 1}
      }
    }

    data = {
      "a" => nil
    }

    # Try out strings
    data["a"] = "t"
    assert_valid schema, data

    data["a"] = "tt"
    refute_valid schema, data

    # Try out non-string
    data["a"] = 5
    assert_valid schema, data
  end


  def test_enum
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
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


  def test_divisible_by
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {"divisibleBy" => 1.1}
      }
    }

    data = {
      "a" => nil
    }

    data["a"] = 3.3
    assert_valid schema, data

    data["a"] = 3.4
    refute_valid schema, data

    schema["properties"]["a"]["divisibleBy"] = 2.0

    data["a"] = 4.0
    assert_valid schema, data

    data["a"] = 'boo'
    assert_valid schema, data

    data["a"] = 5
    schema["properties"]["a"]["divisibleBy"] = 0
    refute_valid schema, data
  end



  def test_disallow
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {"disallow" => "integer"}
      }
    }

    data = {
      "a" => nil
    }


    data["a"] = 'string'
    assert_valid schema, data

    data["a"] = 5
    refute_valid schema, data


    schema["properties"]["a"]["disallow"] = ["integer","string"]
    data["a"] = 'string'
    refute_valid schema, data

    data["a"] = 5
    refute_valid schema, data

    data["a"] = false
    assert_valid schema, data

  end



  def test_extends
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => { "type" => "integer"}
      }
    }

    schema2 = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => { "maximum" => 5 }
      }
    }

    data = {
      "a" => 10
    }

    assert_valid schema, data
    assert(!JSON::Validator.validate(schema2,data))

    schema["extends"] = schema2

    refute_valid schema, data
  end

  def test_pattern_properties
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "patternProperties" => {
        "\\d+ taco" => {"type" => "integer"}
      }
    }

    data = {
      "a" => true,
      "1 taco" => 1,
      "20 tacos" => 20
    }

    assert_valid schema, data
    data["20 tacos"] = "string!"
    refute_valid schema, data
  end


  def test_additional_properties
    # Test no additional properties allowed
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => { "type" => "integer" }
      },
      "additionalProperties" => false
    }

    data = {
      "a" => 10
    }

    assert_valid schema, data
    data["b"] = 5
    refute_valid schema, data

    # Test additional properties match a schema
    schema["additionalProperties"] = { "type" => "string" }
    data["b"] = "taco"
    assert_valid schema, data
    data["b"] = 5
    refute_valid schema, data

    # Make sure this works with pattern properties set, too
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "patternProperties" => {
        "\\d+ taco" => {"type" => "integer"}
      },
      "additionalProperties" => false
    }

    data = {
      "5 tacos" => 5,
      "20 tacos" => 20
    }

    assert_valid schema, data
    data["b"] = 5
    refute_valid schema, data
  end


  def test_items
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "items" => { "type" => "integer" }
    }

    data = [1,2,4]
    assert_valid schema, data
    data = [1,2,"string"]
    refute_valid schema, data

    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "items" => [
        {"type" => "integer"},
        {"type" => "string"}
      ]
    }

    data = [1,"string"]
    assert_valid schema, data
    data = [1,"string",3]
    assert_valid schema, data
    data = ["string",1]
    refute_valid schema, data

    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "items" => [
        {"type" => "integer"},
        {"type" => "string"}
      ],
      "additionalItems" => false
    }

    data = [1,"string"]
    assert_valid schema, data
    data = [1,"string",3]
    refute_valid schema, data

    schema = {"$schema" => "http://json-schema.org/draft-03/schema#","items" => [{"type" => "integer"},{"type" => "string"}],"additionalItems" => {"type" => "integer"}}

    data = [1,"string"]
    assert_valid schema, data
    data = [1,"string",3]
    assert_valid schema, data
    data = [1,"string","string"]
    refute_valid schema, data
  end


  def test_list_option
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "integer", "required" => true} }
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "integer"}, "b" => {"$ref" => "#"}}
    }

    data = {"a" => 5, "b" => {"b" => {"a" => 1}}}
    assert_valid schema, data
    data = {"a" => 5, "b" => {"b" => {"a" => 'taco'}}}
    refute_valid schema, data
  end


  def test_format_ipv4
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "ip-address"}}
    }

    data = {"a" => "1.1.1.1"}
    assert_valid schema, data
    data = {"a" => "1.1.1"}
    refute_valid schema, data
    data = {"a" => "1.1.1.300"}
    refute_valid schema, data
    data = {"a" => 5}
    refute_valid schema, data
    data = {"a" => "1.1.1"}
    refute_valid schema, data
    data = {"a" => "1.1.1.1b"}
    refute_valid schema, data
    data = {"a" => "b1.1.1.1"}
  end


  def test_format_ipv6
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "ipv6"}}
    }

    data = {"a" => "1111:2222:8888:9999:aaaa:cccc:eeee:ffff"}
    assert_valid schema, data
    data = {"a" => "1111:0:8888:0:0:0:eeee:ffff"}
    assert_valid schema, data
    data = {"a" => "1111:2222:8888::eeee:ffff"}
    assert_valid schema, data
    data = {"a" => "1111:2222:8888:99999:aaaa:cccc:eeee:ffff"}
    refute_valid schema, data
    data = {"a" => "1111:2222:8888:9999:aaaa:cccc:eeee:gggg"}
    refute_valid schema, data
    data = {"a" => "1111:2222::9999::cccc:eeee:ffff"}
    refute_valid schema, data
    data = {"a" => "1111:2222:8888:9999:aaaa:cccc:eeee:ffff:bbbb"}
    refute_valid schema, data
    assert(JSON::Validator.validate(schema, {"a" => "::1"}), 'validate with shortcut')
    assert(!JSON::Validator.validate(schema, {"a" => "42"}), 'not validate a simple number')
  end

  def test_format_time
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "time"}}
    }

    data = {"a" => "12:00:00"}
    assert_valid schema, data
    data = {"a" => "12:00"}
    refute_valid schema, data
    data = {"a" => "12:00:60"}
    refute_valid schema, data
    data = {"a" => "12:60:00"}
    refute_valid schema, data
    data = {"a" => "24:00:00"}
    refute_valid schema, data
    data = {"a" => "0:00:00"}
    refute_valid schema, data
    data = {"a" => "-12:00:00"}
    refute_valid schema, data
    data = {"a" => "12:00:00b"}
    refute_valid schema, data
    data = {"a" => "12:00:00\nabc"}
    refute_valid schema, data
  end


  def test_format_date
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "date"}}
    }

    data = {"a" => "2010-01-01"}
    assert_valid schema, data
    data = {"a" => "2010-01-32"}
    refute_valid schema, data
    data = {"a" => "n2010-01-01"}
    refute_valid schema, data
    data = {"a" => "2010-1-01"}
    refute_valid schema, data
    data = {"a" => "2010-01-1"}
    refute_valid schema, data
    data = {"a" => "2010-01-01n"}
    refute_valid schema, data
    data = {"a" => "2010-01-01\nabc"}
    refute_valid schema, data
  end

  def test_format_datetime
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "date-time"}}
    }

    data = {"a" => "2010-01-01T12:00:00Z"}
    assert_valid schema, data
    data = {"a" => "2010-01-01T12:00:00.1Z"}
    assert_valid schema, data
    data = {"a" => "2010-01-01T12:00:00,1Z"}
    assert_valid schema, data
    data = {"a" => "2010-01-32T12:00:00Z"}
    refute_valid schema, data
    data = {"a" => "2010-13-01T12:00:00Z"}
    refute_valid schema, data
    data = {"a" => "2010-01-01T24:00:00Z"}
    refute_valid schema, data
    data = {"a" => "2010-01-01T12:60:00Z"}
    refute_valid schema, data
    data = {"a" => "2010-01-01T12:00:60Z"}
    refute_valid schema, data
    data = {"a" => "2010-01-01T12:00:00z"}
    refute_valid schema, data
    data = {"a" => "2010-01-0112:00:00Z"}
    refute_valid schema, data
    data = {"a" => "2010-01-01T12:00:00.1Z\nabc"}
    refute_valid schema, data

    # test with a specific timezone
    data = {"a" => "2010-01-01T12:00:00+01"}
    assert_valid schema, data
    data = {"a" => "2010-01-01T12:00:00+01:00"}
    assert_valid schema, data
    data = {"a" => "2010-01-01T12:00:00+01:30"}
    assert_valid schema, data
    data = {"a" => "2010-01-01T12:00:00+0234"}
    assert_valid schema, data
    data = {"a" => "2010-01-01T12:00:00+01:"}
    refute_valid schema, data
    data = {"a" => "2010-01-01T12:00:00+0"}
    refute_valid schema, data
    # do not allow mixing Z and specific timezone
    data = {"a" => "2010-01-01T12:00:00Z+01"}
    refute_valid schema, data
    data = {"a" => "2010-01-01T12:00:00+01Z"}
    refute_valid schema, data
    data = {"a" => "2010-01-01T12:00:00+01:30Z"}
    refute_valid schema, data
    data = {"a" => "2010-01-01T12:00:00+0Z"}
    refute_valid schema, data

    # test without any timezone
    data = {"a" => "2010-01-01T12:00:00"}
    assert_valid schema, data
    data = {"a" => "2010-01-01T12:00:00.12345"}
    assert_valid schema, data
    data = {"a" => "2010-01-01T12:00:00,12345"}
    assert_valid schema, data
    data = {"a" => "2010-01-01T12:00:00.12345"}
    assert_valid schema, data
  end

  def test_format_unknown
    schema = {
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "unknown"}}
    }

    data = {"a" => "I can write what I want here"}
    assert(JSON::Validator.validate(schema,data,:version => :draft3))
    data = {"a" => ""}
    assert(JSON::Validator.validate(schema,data,:version => :draft3))
  end


  def test_format_union
    data1 = {"a" => "boo"}
    data2 = {"a" => nil}

    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => ["string","null"], "format" => "ip-address"}}
    }
    assert(!JSON::Validator.validate(schema,data1))
    assert(JSON::Validator.validate(schema,data2))
  end

  def test_format_uri
    data1 = {"a" => "http://gitbuh.com"}
    data2 = {"a" => "::boo"}
    data3 = {"a" => "http://ja.wikipedia.org/wiki/メインページ"}

    schema = {
        "$schema" => "http://json-schema.org/draft-03/schema#",
        "type" => "object",
        "properties" => { "a" => {"type" => "string", "format" => "uri"}}
    }

    assert(JSON::Validator.validate(schema,data1))
    assert(!JSON::Validator.validate(schema,data2))
    assert(JSON::Validator.validate(schema,data3))
  end



  def test_schema
    schema = {
      "$schema" => "http://json-schema.org/THIS-IS-NOT-A-SCHEMA",
      "type" => "object"
    }

    data = {"a" => "taco"}
    assert(!JSON::Validator.validate(schema, data))

    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object"
    }
    assert_valid schema, data
  end

  def test_dependency
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => {
        "a" => {"type" => "integer"},
        "b" => {"type" => "integer"}
      },
      "dependencies" => {
        "a" => "b"
      }
    }

    data = {"a" => 1, "b" => 2}
    assert_valid schema, data
    data = {"a" => 1}
    refute_valid schema, data

    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
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

  def test_default
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => {
        "a" => {"type" => "integer", "default" => 42, "required" => true},
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => {
        "a" => {"type" => "integer", "default" => 42, "required" => true, "readonly" => true},
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
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


end

