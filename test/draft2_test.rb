require File.expand_path('../support/test_helper', __FILE__)

class Draft2Test < Minitest::Test
  def validation_errors(schema, data, options)
    super(schema, data, version: :draft2)
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

  include EnumValidation::General
  include EnumValidation::V1_V2

  include NumberValidation::MinMaxTests
  include NumberValidation::MultipleOfTests

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
      'properties' => {
        'a' => { 'type' => 'string' },
      },
    }
    data = {}

    refute_valid schema, data
    data['a'] = 'Hello'
    assert_valid schema, data

    schema = {
      'properties' => {
        'a' => { 'type' => 'integer', 'optional' => 'true' },
      },
    }

    data = {}
    assert_valid schema, data
  end

  def test_disallow
    # Set up the default datatype
    schema = {
      'properties' => {
        'a' => { 'disallow' => 'integer' },
      },
    }

    data = {
      'a' => nil,
    }

    data['a'] = 'string'
    assert_valid schema, data

    data['a'] = 5
    refute_valid schema, data

    schema['properties']['a']['disallow'] = %w[integer string]
    data['a'] = 'string'
    refute_valid schema, data

    data['a'] = 5
    refute_valid schema, data

    data['a'] = false
    assert_valid schema, data
  end

  def test_format_datetime
    schema = {
      'type' => 'object',
      'properties' => { 'a' => { 'type' => 'string', 'format' => 'date-time' } },
    }

    assert_valid schema, { 'a' => '2010-01-01T12:00:00Z' }
    refute_valid schema, { 'a' => '2010-01-32T12:00:00Z' }
    refute_valid schema, { 'a' => '2010-13-01T12:00:00Z' }
    refute_valid schema, { 'a' => '2010-01-01T24:00:00Z' }
    refute_valid schema, { 'a' => '2010-01-01T12:60:00Z' }
    refute_valid schema, { 'a' => '2010-01-01T12:00:60Z' }
    refute_valid schema, { 'a' => '2010-01-01T12:00:00z' }
    refute_valid schema, { 'a' => '2010-01-0112:00:00Z' }
    refute_valid schema, { 'a' => "2010-01-01T12:00:00Z\nabc" }
  end
end
