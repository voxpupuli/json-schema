require_relative 'test_helper'

class AllOfRefSchemaTest < Test::Unit::TestCase
  def test_all_of_ref_schema_fails
    schema = File.join(File.dirname(__FILE__),"schemas/all_of_ref_schema.json")
    data = File.join(File.dirname(__FILE__),"data/all_of_ref_data.json")
    errors = JSON::Validator.fully_validate(schema,data, :errors_as_objects => true)
    assert(!errors.empty?, "should have failed to validate")
  end

  def test_all_of_ref_schema_succeeds
    schema = File.join(File.dirname(__FILE__),"schemas/all_of_ref_schema.json")
    data   = %({"name": 42})
    errors = JSON::Validator.fully_validate(schema,data, :errors_as_objects => true)
    assert(errors.empty?, "should have validated")
  end

  def test_all_of_ref_subschema_errors
    schema = File.join(File.dirname(__FILE__), 'schemas/all_of_ref_schema.json')
    data = File.join(File.dirname(__FILE__), 'data/all_of_ref_data.json')
    errors = JSON::Validator.fully_validate(schema, data, :errors_as_objects => true)
    nested_errors = errors[0][:errors]
    assert_equal([:allof_0], nested_errors.keys, 'should have nested errors for each allOf subschema')
    assert_match(/the property '#\/name' of type String did not match the following type: integer/i, nested_errors[:allof_0][0][:message])
  end

  def test_all_of_ref_message
    schema = File.join(File.dirname(__FILE__), 'schemas/all_of_ref_schema.json')
    data = File.join(File.dirname(__FILE__), 'data/all_of_ref_data.json')
    errors = JSON::Validator.fully_validate(schema, data)
    expected_message = """The property '#/' of type Hash did not match all of the required schemas. The schema specific errors were:

- allOf #0:
    - The property '#/name' of type String did not match the following type: integer"""
    assert_equal(expected_message, errors[0])
  end
end
