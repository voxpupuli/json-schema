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

  def multiple_of
    'divisibleBy'
  end

  include ArrayValidation::ItemsTests
  include ArrayValidation::UniqueItemsTests

  include NumberValidation::MinMaxTests
  include NumberValidation::MultipleOfTests

  include ObjectValidation::AdditionalPropertiesTests

  include StringValidation::ValueTests

  include TypeValidation::SimpleTypeTests
  include TypeValidation::AnyTypeTests
  include TypeValidation::SchemaUnionTypeTests

  def test_optional
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"type" => "string"}
      }
    }
    data = {}

    refute_valid schema, data
    data['a'] = "Hello"
    assert_valid schema, data

    schema = {
      "properties" => {
        "a" => {"type" => "integer", "optional" => "true"}
      }
    }

    data = {}
    assert_valid schema, data
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

  def test_format_ipv4
    schema = {
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
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "date-time"}}
    }

    assert_valid schema, {"a" => "2010-01-01T12:00:00Z"}
    refute_valid schema, {"a" => "2010-01-32T12:00:00Z"}
    refute_valid schema, {"a" => "2010-13-01T12:00:00Z"}
    refute_valid schema, {"a" => "2010-01-01T24:00:00Z"}
    refute_valid schema, {"a" => "2010-01-01T12:60:00Z"}
    refute_valid schema, {"a" => "2010-01-01T12:00:60Z"}
    refute_valid schema, {"a" => "2010-01-01T12:00:00z"}
    refute_valid schema, {"a" => "2010-01-0112:00:00Z"}
    refute_valid schema, {"a" => "2010-01-01T12:00:00Z\nabc"}
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
      "type" => "object",
      "properties" => { "a" => {"type" => ["string","null"], "format" => "ip-address"}}
    }
    refute_valid schema, data1
    assert_valid schema, data2
  end

end

