# encoding: utf-8

require File.expand_path('../support/test_helper', __FILE__)

module StrictValidationV4
  def test_strict_properties
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'properties' => {
        'a' => { 'type' => 'string' },
        'b' => { 'type' => 'string' },
      },
    }

    data = { 'a' => 'a' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'b' => 'b' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b' }
    assert(JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b', 'c' => 'c' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(!JSON::Validator.validate(schema, data, noAdditionalProperties: true))
  end

  def test_strict_properties_additional_props
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'properties' => {
        'a' => { 'type' => 'string' },
        'b' => { 'type' => 'string' },
      },
      'additionalProperties' => { 'type' => 'integer' },
    }

    data = { 'a' => 'a' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'b' => 'b' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b' }
    assert(JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b', 'c' => 'c' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(!JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b', 'c' => 3 }
    assert(JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))
  end

  def test_strict_properties_pattern_props
    schema = {
      '$schema' => 'http://json-schema.org/draft-03/schema#',
      'properties' => {
        'a' => { 'type' => 'string' },
        'b' => { 'type' => 'string' },
      },
      'patternProperties' => { '\\d+ taco' => { 'type' => 'integer' } },
    }

    data = { 'a' => 'a' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'b' => 'b' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b' }
    assert(JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b', 'c' => 'c' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(!JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b', 'c' => 3 }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(!JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b', '23 taco' => 3 }
    assert(JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b', '23 taco' => 'cheese' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(!JSON::Validator.validate(schema, data, noAdditionalProperties: true))
  end
end

class Draft4Test < Minitest::Test
  def validation_errors(schema, data, options)
    super(schema, data, version: :draft4)
  end

  def exclusive_minimum
    { 'exclusiveMinimum' => true }
  end

  def exclusive_maximum
    { 'exclusiveMaximum' => true }
  end

  def ipv4_format
    'ipv4'
  end

  include ArrayValidation::ItemsTests
  include ArrayValidation::AdditionalItemsTests
  include ArrayValidation::UniqueItemsTests

  include EnumValidation::General
  include EnumValidation::V3_V4

  include NumberValidation::MinMaxTests
  include NumberValidation::MultipleOfTests

  include ObjectValidation::AdditionalPropertiesTests
  include ObjectValidation::PatternPropertiesTests

  include StrictValidation
  include StrictValidationV4

  include StringValidation::ValueTests
  include StringValidation::FormatTests

  include TypeValidation::SimpleTypeTests

  def test_required
    # Set up the default datatype
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'required' => ['a'],
      'properties' => {
        'a' => {},
      },
    }
    data = {}

    refute_valid schema, data
    data['a'] = 'Hello'
    assert_valid schema, data

    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'properties' => {
        'a' => { 'type' => 'integer' },
      },
    }

    data = {}
    assert_valid schema, data
  end

  def test_min_properties
    schema = { 'minProperties' => 2 }

    assert_valid schema, { 'a' => 1, 'b' => 2 }
    assert_valid schema, { 'a' => 1, 'b' => 2, 'c' => 3 }

    refute_valid schema, { 'a' => 1 }
    refute_valid schema, {}
  end

  def test_max_properties
    schema = { 'maxProperties' => 2 }

    assert_valid schema, { 'a' => 1, 'b' => 2 }
    assert_valid schema, { 'a' => 1 }
    assert_valid schema, {}

    refute_valid schema, { 'a' => 1, 'b' => 2, 'c' => 3 }
  end

  def test_list_option
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
      'required' => ['a'],
      'properties' => { 'a' => { 'type' => 'integer' } },
    }

    data = [{ 'a' => 1 }, { 'a' => 2 }, { 'a' => 3 }]
    assert(JSON::Validator.validate(schema, data, list: true))
    refute_valid schema, data

    data = { 'a' => 1 }
    assert(!JSON::Validator.validate(schema, data, list: true))

    data = [{ 'a' => 1 }, { 'b' => 2 }, { 'a' => 3 }]
    assert(!JSON::Validator.validate(schema, data, list: true))
  end

  def test_default_with_strict_and_anyof
    schema = {
      'anyOf' => [
        {
          'type' => 'object',
          'properties' => {
            'foo' => {
              'enum' => %w[view search],
              'default' => 'view',
            },
          },
        },
        {
          'type' => 'object',
          'properties' => {
            'bar' => {
              'type' => 'string',
            },
          },
        },
      ],
    }

    data = {
      'bar' => 'baz',
    }

    assert(JSON::Validator.validate(schema, data, insert_defaults: true, strict: true))
  end

  def test_default_with_anyof
    schema = {
      'anyOf' => [
        {
          'type' => 'object',
          'properties' => {
            'foo' => {
              'enum' => %w[view search],
              'default' => 'view',
            },
          },
        },
        {
          'type' => 'object',
          'properties' => {
            'bar' => {
              'type' => 'string',
            },
          },
        },
      ],
    }

    data = {}

    assert(JSON::Validator.validate(schema, data, insert_defaults: true, strict: true))
    assert(data['foo'] == 'view')
  end

  def test_default_with_strict_and_oneof
    schema = {
      'oneOf' => [
        {
          'type' => 'object',
          'properties' => {
            'bar' => {
              'type' => 'string',
            },
          },
        },
        {
          'type' => 'object',
          'properties' => {
            'foo' => {
              'enum' => %w[view search],
              'default' => 'view',
            },
          },
        },
      ],
    }

    data = {
      'bar' => 'baz',
    }

    assert(JSON::Validator.validate(schema, data, insert_defaults: true, strict: true))
    assert(!data.key?('foo'))
  end

  def test_self_reference
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
      'properties' => { 'a' => { 'type' => 'integer' }, 'b' => { '$ref' => '#' } },
    }

    assert_valid schema, { 'a' => 5, 'b' => { 'b' => { 'a' => 1 } } }
    refute_valid schema, { 'a' => 5, 'b' => { 'b' => { 'a' => 'taco' } } }
  end

  def test_property_named_ref
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'properties' => {
        '$ref' => {
          'type' => 'integer',
        },
      },
    }

    assert_valid schema, { '$ref' => 1 }
    refute_valid schema, { '$ref' => '#' }
  end

  def test_format_datetime
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
      'properties' => { 'a' => { 'type' => 'string', 'format' => 'date-time' } },
    }

    assert_valid schema, { 'a' => '2010-01-01T12:00:00Z' }
    assert_valid schema, { 'a' => '2010-01-01T12:00:00.1Z' }
    refute_valid schema, { 'a' => '2010-01-01T12:00:00,1Z' }
    refute_valid schema, { 'a' => '2010-01-01T12:00:00+0000' }
    assert_valid schema, { 'a' => '2010-01-01T12:00:00+00:00' }
    refute_valid schema, { 'a' => '2010-01-32T12:00:00Z' }
    refute_valid schema, { 'a' => '2010-13-01T12:00:00Z' }
    assert_valid schema, { 'a' => '2010-01-01T24:00:00Z' }
    refute_valid schema, { 'a' => '2010-01-01T12:60:00Z' }
    assert_valid schema, { 'a' => '2010-01-01T12:00:60Z' }
    assert_valid schema, { 'a' => '2010-01-01T12:00:00z' }
    refute_valid schema, { 'a' => '2010-01-0112:00:00Z' }
  end

  def test_format_uri
    data1 = { 'a' => 'http://gitbuh.com' }
    data2 = { 'a' => '::boo' }
    data3 = { 'a' => 'http://ja.wikipedia.org/wiki/メインページ' }

    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
      'properties' => { 'a' => { 'type' => 'string', 'format' => 'uri' } },
    }

    assert(JSON::Validator.validate(schema, data1))
    assert(!JSON::Validator.validate(schema, data2))
    assert(JSON::Validator.validate(schema, data3))
  end

  def test_schema
    schema = {
      '$schema' => 'http://json-schema.org/THIS-IS-NOT-A-SCHEMA',
      'type' => 'object',
    }

    data = { 'a' => 'taco' }
    assert(!JSON::Validator.validate(schema, data))

    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
    }
    assert_valid schema, data
  end

  def test_dependency
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
      'properties' => {
        'a' => { 'type' => 'integer' },
        'b' => { 'type' => 'integer' },
      },
      'dependencies' => {
        'a' => ['b'],
      },
    }

    data = { 'a' => 1, 'b' => 2 }
    assert_valid schema, data
    data = { 'a' => 1 }
    refute_valid schema, data

    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
      'properties' => {
        'a' => { 'type' => 'integer' },
        'b' => { 'type' => 'integer' },
        'c' => { 'type' => 'integer' },
      },
      'dependencies' => {
        'a' => %w[b c],
      },
    }

    data = { 'a' => 1, 'c' => 2 }
    refute_valid schema, data
    data = { 'a' => 1, 'b' => 2, 'c' => 3 }
    assert_valid schema, data
  end

  def test_schema_dependency
    schema = {
      'type' => 'object',
      'properties' => {
        'name' => { 'type' => 'string' },
        'credit_card' => { 'type' => 'number' },
      },
      'required' => ['name'],
      'dependencies' => {
        'credit_card' => {
          'properties' => {
            'billing_address' => { 'type' => 'string' },
          },
          'required' => ['billing_address'],
        },
      },
    }
    data = {
      'name' => 'John Doe',
      'credit_card' => 5555555555555555,
    }
    assert(!JSON::Validator.validate(schema, data), 'test schema dependency with invalid data')
    data['billing_address'] = 'Somewhere over the rainbow'
    assert(JSON::Validator.validate(schema, data), 'test schema dependency with valid data')
  end

  def test_default
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
      'properties' => {
        'a' => { 'type' => 'integer', 'default' => 42 },
        'b' => { 'type' => 'integer' },
      },
    }

    data = { b: 2 }
    assert_valid schema, data
    assert_nil(data['a'])
    assert(JSON::Validator.validate(schema, data, insert_defaults: true))
    assert_equal(42, data['a'])
    assert_equal(2, data[:b])

    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
      'required' => ['a'],
      'properties' => {
        'a' => { 'type' => 'integer', 'default' => 42 },
        'b' => { 'type' => 'integer' },
      },
    }

    data = { b: 2 }
    refute_valid schema, data
    assert_nil(data['a'])
    assert(JSON::Validator.validate(schema, data, insert_defaults: true))
    assert_equal(42, data['a'])
    assert_equal(2, data[:b])

    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
      'required' => ['a'],
      'properties' => {
        'a' => { 'type' => 'integer', 'default' => 42, 'readonly' => true },
        'b' => { 'type' => 'integer' },
      },
    }

    data = { b: 2 }
    refute_valid schema, data
    assert_nil(data['a'])
    assert(!JSON::Validator.validate(schema, data, insert_defaults: true))
    assert_nil(data['a'])
    assert_equal(2, data[:b])

    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
      'properties' => {
        'a' => { 'type' => 'integer', 'default' => '42' },
        'b' => { 'type' => 'integer' },
      },
    }

    data = { b: 2 }
    assert_valid schema, data
    assert_nil(data['a'])
    assert(!JSON::Validator.validate(schema, data, insert_defaults: true))
    assert_equal('42', data['a'])
    assert_equal(2, data[:b])
  end

  def test_boolean_false_default
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
      'required' => ['a'],
      'properties' => {
        'a' => { 'type' => 'boolean', 'default' => false },
        'b' => { 'type' => 'integer' },
      },
    }

    data = { b: 2 }
    refute_valid schema, data
    assert_nil(data['a'])
    assert(JSON::Validator.validate(schema, data, insert_defaults: true))
    assert_equal(false, data['a'])
    assert_equal(2, data[:b])
  end

  def test_all_of
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'allOf' => [
        {
          'properties' => { 'a' => { 'type' => 'string' } },
          'required' => ['a'],
        },
        {
          'properties' => { 'b' => { 'type' => 'integer' } },
        },
      ],
    }

    data = { 'a' => 'hello', 'b' => 5 }
    assert_valid schema, data

    data = { 'a' => 'hello' }
    assert_valid schema, data

    data = { 'a' => 'hello', 'b' => 'taco' }
    refute_valid schema, data

    data = { 'b' => 5 }
    refute_valid schema, data
  end

  def test_any_of
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'anyOf' => [
        {
          'properties' => { 'a' => { 'type' => 'string' } },
          'required' => ['a'],
        },
        {
          'properties' => { 'b' => { 'type' => 'integer' } },
        },
      ],
    }

    data = { 'a' => 'hello', 'b' => 5 }
    assert_valid schema, data

    data = { 'a' => 'hello' }
    assert_valid schema, data

    data = { 'a' => 'hello', 'b' => 'taco' }
    assert_valid schema, data

    data = { 'b' => 5 }
    assert_valid schema, data

    data = { 'a' => 5, 'b' => 'taco' }
    refute_valid schema, data
  end

  def test_one_of
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'oneOf' => [
        {
          'properties' => { 'a' => { 'type' => 'string' } },
          'required' => ['a'],
        },
        {
          'properties' => { 'b' => { 'type' => 'integer' } },
        },
      ],
    }

    data = { 'a' => 'hello', 'b' => 5 }
    refute_valid schema, data

    # This passes because b is not required, thus matches both schemas
    data = { 'a' => 'hello' }
    refute_valid schema, data

    data = { 'a' => 'hello', 'b' => 'taco' }
    assert_valid schema, data

    data = { 'b' => 5 }
    assert_valid schema, data

    data = { 'a' => 5, 'b' => 'taco' }
    refute_valid schema, data
  end

  def test_not
    # Start with a simple not
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'properties' => {
        'a' => { 'not' => { 'type' => %w[string boolean] } },
      },
    }

    data = { 'a' => 1 }
    assert_valid schema, data

    data = { 'a' => 'hi!' }
    refute_valid schema, data

    data = { 'a' => true }
    refute_valid schema, data

    # Sub-schema not
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'properties' => {
        'a' => { 'not' => { 'anyOf' => [
          {
            'type' => %w[string boolean],
          },
          {
            'type' => 'object',
            'properties' => {
              'b' => { 'type' => 'boolean' },
            },
          },
        ] } },
      },
    }

    data = { 'a' => 1 }
    assert_valid schema, data

    data = { 'a' => 'hi!' }
    refute_valid schema, data

    data = { 'a' => true }
    refute_valid schema, data

    data = { 'a' => { 'b' => true } }
    refute_valid schema, data

    data = { 'a' => { 'b' => 5 } }
    assert_valid schema, data
  end

  def test_not_fully_validate
    # Start with a simple not
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'properties' => {
        'a' => { 'not' => { 'type' => %w[string boolean] } },
      },
    }

    data = { 'a' => 1 }
    errors = JSON::Validator.fully_validate(schema, data)
    assert_equal(0, errors.length)

    data = { 'a' => 'taco' }
    errors = JSON::Validator.fully_validate(schema, data)
    assert_equal(1, errors.length)
  end

  def test_definitions
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'array',
      'items' => { '$ref' => '#/definitions/positiveInteger' },
      'definitions' => {
        'positiveInteger' => {
          'type' => 'integer',
          'minimum' => 0,
          'exclusiveMinimum' => true,
        },
      },
    }

    data = [1, 2, 3]
    assert_valid schema, data

    data = [-1, 2, 3]
    refute_valid schema, data
  end
end
