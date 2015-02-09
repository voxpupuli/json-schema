require File.expand_path('../test_helper', __FILE__)

class JSONSchemaDraft1Test < Minitest::Test
  def schema_version
    :draft1
  end

  def exclusive_minimum
    { 'minimumCanEqual' => false }
  end

  def exclusive_maximum
    { 'maximumCanEqual' => false }
  end

  include ArrayValidation::ItemsTests

  include NumberValidation::MinMaxTests

  include ObjectValidation::AdditionalPropertiesTests

  include StrictValidation

  include StringValidation::ValueTests
  include StringValidation::FormatTests
  include StringValidation::DateAndTimeFormatTests

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


  def test_max_decimal
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"maxDecimal" => 2}
      }
    }

    data = {
      "a" => nil
    }

    data["a"] = 3.35
    assert_valid schema, data

    data["a"] = 3.455
    refute_valid schema, data


    schema["properties"]["a"]["maxDecimal"] = 0

    data["a"] = 4.0
    refute_valid schema, data

    data["a"] = 'boo'
    assert_valid schema, data

    data["a"] = 5
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

end

