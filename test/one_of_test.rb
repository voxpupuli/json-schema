require File.expand_path('../support/test_helper', __FILE__)

class OneOfTest < Minitest::Test
  def test_one_of_links_schema
    schema = schema_fixture_path('one_of_ref_links_schema.json')
    data   = data_fixture_path('one_of_ref_links_data.json')
    assert_valid schema, data
  end

  def test_one_of_with_string_patterns
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'oneOf' => [
        {
          'properties' => { 'a' => { 'type' => 'string', 'pattern' => 'foo' } },
        },
        {
          'properties' => { 'a' => { 'type' => 'string', 'pattern' => 'bar' } },
        },
        {
          'properties' => { 'a' => { 'type' => 'string', 'pattern' => 'baz' } },
        },
      ],
    }

    assert_valid schema, { 'a' => 'foo' }
    refute_valid schema, { 'a' => 'foobar' }
    assert_valid schema, { 'a' => 'baz' }
    refute_valid schema, { 'a' => 5 }
  end

  def test_one_of_sub_errors
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'oneOf' => [
        {
          'properties' => { 'a' => { 'type' => 'string', 'pattern' => 'foo' } },
        },
        {
          'properties' => { 'a' => { 'type' => 'string', 'pattern' => 'bar' } },
        },
        {
          'properties' => { 'a' => { 'type' => 'number', 'minimum' => 10 } },
        },
      ],
    }

    errors = JSON::Validator.fully_validate(schema, { 'a' => 5 }, errors_as_objects: true)
    nested_errors = errors[0][:errors]
    assert_equal(%i[oneof_0 oneof_1 oneof_2], nested_errors.keys, 'should have nested errors for each allOf subschema')
    assert_match(%r{the property '#/a' of type Integer did not match the following type: string}i, nested_errors[:oneof_0][0][:message])
    assert_match(%r{the property '#/a' did not have a minimum value of 10, inclusively}i, nested_errors[:oneof_2][0][:message])
  end

  def test_one_of_sub_errors_message
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'oneOf' => [
        {
          'properties' => { 'a' => { 'type' => 'string', 'pattern' => 'foo' } },
        },
        {
          'properties' => { 'a' => { 'type' => 'string', 'pattern' => 'bar' } },
        },
        {
          'properties' => { 'a' => { 'type' => 'number', 'minimum' => 10 } },
        },
      ],
    }

    errors = JSON::Validator.fully_validate(schema, { 'a' => 5 })
    expected_message = ''"The property '#/' of type object did not match any of the required schemas. The schema specific errors were:

- oneOf #0:
    - The property '#/a' of type integer did not match the following type: string
- oneOf #1:
    - The property '#/a' of type integer did not match the following type: string
- oneOf #2:
    - The property '#/a' did not have a minimum value of 10, inclusively"''

    assert_equal(expected_message, errors[0])
  end
end
