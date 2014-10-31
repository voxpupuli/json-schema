# encoding: utf-8
require File.expand_path('../test_helper', __FILE__)

class JSONSchemaDraft3Test < MiniTest::Unit::TestCase
  def schema_version
    :draft3
  end

  def exclusive_minimum
    { 'exclusiveMinimum' => true }
  end

  def exclusive_maximum
    { 'exclusiveMaximum' => true }
  end

  include ArrayValidation::ItemsTests
  include ArrayValidation::AdditionalItemsTests
  include ArrayValidation::UniqueItemsTests

  include NumberValidation::MinMaxTests

  include ObjectValidation::AdditionalPropertiesTests
  include ObjectValidation::PatternPropertiesTests

  include StringValidation::ValueTests

  include TypeValidation::SimpleTypeTests
  include TypeValidation::AnyTypeTests
  include TypeValidation::SchemaUnionTypeTests

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

    assert_valid schema, {"a" => 5, "b" => {"b" => {"a" => 1}}}
    refute_valid schema, {"a" => 5, "b" => {"b" => {"a" => 'taco'}}}
  end


  def test_format_ipv4
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "ip-address"}}
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
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

  def test_format_time
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "time"}}
    }

    assert_valid schema, {"a" => "12:00:00"}
    refute_valid schema, {"a" => "12:00"}
    refute_valid schema, {"a" => "12:00:60"}
    refute_valid schema, {"a" => "12:60:00"}
    refute_valid schema, {"a" => "24:00:00"}
    refute_valid schema, {"a" => "0:00:00"}
    refute_valid schema, {"a" => "-12:00:00"}
    refute_valid schema, {"a" => "12:00:00b"}
    refute_valid schema, {"a" => "12:00:00\nabc"}
  end


  def test_format_date
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "date"}}
    }

    assert_valid schema, {"a" => "2010-01-01"}
    refute_valid schema, {"a" => "2010-01-32"}
    refute_valid schema, {"a" => "n2010-01-01"}
    refute_valid schema, {"a" => "2010-1-01"}
    refute_valid schema, {"a" => "2010-01-1"}
    refute_valid schema, {"a" => "2010-01-01n"}
    refute_valid schema, {"a" => "2010-01-01\nabc"}
  end

  def test_format_datetime
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "date-time"}}
    }

    assert_valid schema, {"a" => "2010-01-01T12:00:00Z"}
    assert_valid schema, {"a" => "2010-01-01T12:00:00.1Z"}
    assert_valid schema, {"a" => "2010-01-01T12:00:00,1Z"}
    refute_valid schema, {"a" => "2010-01-32T12:00:00Z"}
    refute_valid schema, {"a" => "2010-13-01T12:00:00Z"}
    refute_valid schema, {"a" => "2010-01-01T24:00:00Z"}
    refute_valid schema, {"a" => "2010-01-01T12:60:00Z"}
    refute_valid schema, {"a" => "2010-01-01T12:00:60Z"}
    refute_valid schema, {"a" => "2010-01-01T12:00:00z"}
    refute_valid schema, {"a" => "2010-01-0112:00:00Z"}
    refute_valid schema, {"a" => "2010-01-01T12:00:00.1Z\nabc"}

    # test with a specific timezone
    assert_valid schema, {"a" => "2010-01-01T12:00:00+01"}
    assert_valid schema, {"a" => "2010-01-01T12:00:00+01:00"}
    assert_valid schema, {"a" => "2010-01-01T12:00:00+01:30"}
    assert_valid schema, {"a" => "2010-01-01T12:00:00+0234"}
    refute_valid schema, {"a" => "2010-01-01T12:00:00+01:"}
    refute_valid schema, {"a" => "2010-01-01T12:00:00+0"}
    # do not allow mixing Z and specific timezone
    refute_valid schema, {"a" => "2010-01-01T12:00:00Z+01"}
    refute_valid schema, {"a" => "2010-01-01T12:00:00+01Z"}
    refute_valid schema, {"a" => "2010-01-01T12:00:00+01:30Z"}
    refute_valid schema, {"a" => "2010-01-01T12:00:00+0Z"}

    # test without any timezone
    assert_valid schema, {"a" => "2010-01-01T12:00:00"}
    assert_valid schema, {"a" => "2010-01-01T12:00:00.12345"}
    assert_valid schema, {"a" => "2010-01-01T12:00:00,12345"}
    assert_valid schema, {"a" => "2010-01-01T12:00:00.12345"}
  end

  def test_format_unknown
    schema = {
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "unknown"}}
    }

    assert_valid schema, {'a' => 'I can write what I want here'}
    assert_valid schema, {'a' => ''}
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

