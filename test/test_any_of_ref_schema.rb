require_relative 'test_helper'

class AnyOfRefSchemaTest < Test::Unit::TestCase
  def test_any_of_ref_schema
    schema = File.join(File.dirname(__FILE__),"schemas/any_of_ref_schema.json")
    data = File.join(File.dirname(__FILE__),"data/any_of_ref_data.json")
    errors = JSON::Validator.fully_validate(schema,data, :errors_as_objects => true)
    assert(errors.empty?, errors.map{|e| e[:message] }.join("\n"))
  end

  def test_any_of_ref_subschema_errors
    schema = File.join(File.dirname(__FILE__),'schemas/any_of_ref_schema.json')
    data = %({"names": ["jack"]})
    errors = JSON::Validator.fully_validate(schema, data, :errors_as_objects => true)
    nested_errors = errors[0][:errors]
    assert_equal([:anyof_0, :anyof_1, :anyof_2], nested_errors.keys, 'should have nested errors for each anyOf subschema')
    assert_match(/the property '#\/names\/0' value "jack" did not match the regex 'john'/i, nested_errors[:anyof_0][0][:message])
    assert_match(/the property '#\/names\/0' value "jack" did not match the regex 'jane'/i, nested_errors[:anyof_1][0][:message])
    assert_match(/the property '#\/names\/0' value "jack" did not match the regex 'jimmy'/i, nested_errors[:anyof_2][0][:message])
  end

  def test_any_of_ref_message
    schema = File.join(File.dirname(__FILE__),'schemas/any_of_ref_schema.json')
    data = %({"names": ["jack"]})
    errors = JSON::Validator.fully_validate(schema, data)
    expected_message = """The property '#/names/0' of type String did not match one or more of the required schemas. The schema specific errors were:

- anyOf #0:
    - The property '#/names/0' value \"jack\" did not match the regex 'john'
- anyOf #1:
    - The property '#/names/0' value \"jack\" did not match the regex 'jane'
- anyOf #2:
    - The property '#/names/0' value \"jack\" did not match the regex 'jimmy'"""
    assert_equal(expected_message, errors[0])
  end
end
