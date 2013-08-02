require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class AnyOfRefSchemaTest < Test::Unit::TestCase
  def test_all_of_ref_schema
    schema = File.join(File.dirname(__FILE__),"schemas/any_of_ref_schema.json")
    data = File.join(File.dirname(__FILE__),"data/any_of_ref_data.json")
    errors = JSON::Validator.fully_validate(schema,data, :errors_as_objects => true)
    assert(errors.empty?, errors.map{|e| e[:message] }.join("\n"))
  end
end
