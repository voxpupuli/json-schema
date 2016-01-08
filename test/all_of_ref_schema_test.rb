require File.expand_path('../support/test_helper', __FILE__)

class AllOfRefSchemaTest < Minitest::Test
  def schema
    schema_fixture_path('all_of_ref_schema.json')
  end

  def data
    data_fixture_path('all_of_ref_data.json')
  end

  def test_all_of_ref_schema_fails
    refute_valid schema, data
  end

  def test_all_of_ref_schema_succeeds
    assert_valid schema, %({"name": 42})
  end

  def test_all_of_ref_subschema_errors
    errors = JSON::Validator.fully_validate(schema, data, :errors_as_objects => true)
    nested_errors = errors[0][:errors]
    assert_equal([:allof_0], nested_errors.keys, 'should have nested errors for each allOf subschema')
    assert_match(/the property '#\/name' of type String did not match the following type: integer/i, nested_errors[:allof_0][0][:message])
  end

  def test_all_of_ref_message
    errors = JSON::Validator.fully_validate(schema, data)
    expected_message = """The property '#/' of type Hash did not match all of the required schemas. The schema specific errors were:

- allOf #0:
    - The property '#/name' of type String did not match the following type: integer"""
    assert_equal(expected_message, errors[0])
  end
end
