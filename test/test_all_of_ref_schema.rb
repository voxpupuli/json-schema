require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

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
end
