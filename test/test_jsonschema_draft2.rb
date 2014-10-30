require File.expand_path('../test_helper', __FILE__)

class JSONSchemaDraft2Test < MiniTest::Unit::TestCase
  def schema_version
    :draft2
  end

  def exclusive_minimum
    { 'minimumCanEqual' => false }
  end

  def exclusive_maximum
    { 'maximumCanEqual' => false }
  end

  include TypeValidationTests
  include SchemaUnionTypeValidationTests
  include AnyTypeValidationTests
  include ArrayPropertyValidationTests
  include ArrayUniqueItemsValidationTests
  include NumberPropertyValidationTests
  include StringPropertyValidationTests

  def test_optional
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"type" => "string"}
      }
    }
    data = {}

    refute_valid schema, data, :version => :draft2
    data['a'] = "Hello"
    assert_valid schema, data, :version => :draft2

    schema = {
      "properties" => {
        "a" => {"type" => "integer", "optional" => "true"}
      }
    }

    data = {}
    assert_valid schema, data, :version => :draft2
  end

  def test_enum
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"enum" => [1,'boo',[1,2,3],{"a" => "b"}], "optional" => true}
      }
    }

    data = {
      "a" => nil
    }

    # Make sure all of the above are valid...
    data["a"] = 1
    assert_valid schema, data, :version => :draft2

    data["a"] = 'boo'
    assert_valid schema, data, :version => :draft2

    data["a"] = [1,2,3]
    assert_valid schema, data, :version => :draft2

    data["a"] = {"a" => "b"}
    assert_valid schema, data, :version => :draft2

    # Test something that doesn't exist
    data["a"] = 'taco'
    refute_valid schema, data, :version => :draft2

    # Try it without the key
    data = {}
    assert_valid schema, data, :version => :draft2
  end


  def test_divisible_by
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"divisibleBy" => 1.1}
      }
    }

    data = {
      "a" => nil
    }

    data["a"] = 3.3
    assert_valid schema, data, :version => :draft2

    data["a"] = 3.4
    refute_valid schema, data, :version => :draft2

    schema["properties"]["a"]["divisibleBy"] = 2.0

    data["a"] = 4.0
    assert_valid schema, data, :version => :draft2

    data["a"] = 'boo'
    assert_valid schema, data, :version => :draft2

    data["a"] = 5
    schema["properties"]["a"]["divisibleBy"] = 0
    refute_valid schema, data, :version => :draft2
  end



  def test_disallow
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"disallow" => "integer"}
      }
    }

    data = {
      "a" => nil
    }


    data["a"] = 'string'
    assert_valid schema, data, :version => :draft2

    data["a"] = 5
    refute_valid schema, data, :version => :draft2


    schema["properties"]["a"]["disallow"] = ["integer","string"]
    data["a"] = 'string'
    refute_valid schema, data, :version => :draft2

    data["a"] = 5
    refute_valid schema, data, :version => :draft2

    data["a"] = false
    assert_valid schema, data, :version => :draft2

  end



  def test_additional_properties
    # Test no additional properties allowed
    schema = {
      "properties" => {
        "a" => { "type" => "integer" }
      },
      "additionalProperties" => false
    }

    data = {
      "a" => 10
    }

    assert_valid schema, data, :version => :draft2
    data["b"] = 5
    refute_valid schema, data, :version => :draft2

    # Test additional properties match a schema
    schema["additionalProperties"] = { "type" => "string" }
    data["b"] = "taco"
    assert_valid schema, data, :version => :draft2
    data["b"] = 5
    refute_valid schema, data, :version => :draft2
  end

  def test_format_ipv4
    schema = {
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "ip-address"}}
    }

    data = {"a" => "1.1.1.1"}
    assert_valid schema, data, :version => :draft2
    data = {"a" => "1.1.1"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "1.1.1.300"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => 5}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "1.1.1"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "1.1.1.1b"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "b1.1.1.1"}
  end


  def test_format_ipv6
    schema = {
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "ipv6"}}
    }

    data = {"a" => "1111:2222:8888:9999:aaaa:cccc:eeee:ffff"}
    assert_valid schema, data, :version => :draft2
    data = {"a" => "1111:0:8888:0:0:0:eeee:ffff"}
    assert_valid schema, data, :version => :draft2
    data = {"a" => "1111:2222:8888::eeee:ffff"}
    assert_valid schema, data, :version => :draft2
    data = {"a" => "1111:2222:8888:99999:aaaa:cccc:eeee:ffff"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "1111:2222:8888:9999:aaaa:cccc:eeee:gggg"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "1111:2222::9999::cccc:eeee:ffff"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "1111:2222:8888:9999:aaaa:cccc:eeee:ffff:bbbb"}
    refute_valid schema, data, :version => :draft2
    assert(JSON::Validator.validate(schema, {"a" => "::1"}, :version => :draft2), 'validate with shortcut')
    assert(!JSON::Validator.validate(schema, {"a" => "42"}, :version => :draft2), 'not validate a simple number')
  end

  def test_format_time
    schema = {
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "time"}}
    }

    data = {"a" => "12:00:00"}
    assert_valid schema, data, :version => :draft2
    data = {"a" => "12:00"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "12:00:60"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "12:60:00"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "24:00:00"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "0:00:00"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "-12:00:00"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "12:00:00b"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "12:00:00\nabc"}
    refute_valid schema, data, :version => :draft2
  end


  def test_format_date
    schema = {
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "date"}}
    }

    data = {"a" => "2010-01-01"}
    assert_valid schema, data, :version => :draft2
    data = {"a" => "2010-01-32"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "n2010-01-01"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "2010-1-01"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "2010-01-1"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "2010-01-01n"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "2010-01-01\nabc"}
    refute_valid schema, data, :version => :draft2
  end

  def test_format_datetime
    schema = {
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "date-time"}}
    }

    data = {"a" => "2010-01-01T12:00:00Z"}
    assert_valid schema, data, :version => :draft2
    data = {"a" => "2010-01-32T12:00:00Z"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "2010-13-01T12:00:00Z"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "2010-01-01T24:00:00Z"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "2010-01-01T12:60:00Z"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "2010-01-01T12:00:60Z"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "2010-01-01T12:00:00z"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "2010-01-0112:00:00Z"}
    refute_valid schema, data, :version => :draft2
    data = {"a" => "2010-01-01T12:00:00Z\nabc"}
    refute_valid schema, data, :version => :draft2
  end

  def test_format_unknown
    schema = {
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "unknown"}}
    }

    data = {"a" => "I can write what I want here"}
    assert_valid schema, data, :version => :draft2
    data = {"a" => ""}
    assert_valid schema, data, :version => :draft2
  end


  def test_format_union
    data1 = {"a" => "boo"}
    data2 = {"a" => nil}

    schema = {
      "type" => "object",
      "properties" => { "a" => {"type" => ["string","null"], "format" => "ip-address"}}
    }
    refute_valid schema, data1, :version => :draft2
    assert_valid schema, data2, :version => :draft2
  end

end

