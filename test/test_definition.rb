require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class RelativeDefinitionTest < Test::Unit::TestCase

  def test_definition_schema
    schema = File.join(File.dirname(__FILE__),"schemas/definition_schema.json")
    data = {"a" => 5}
    errors = JSON::Validator.fully_validate(schema,data, :errors_as_objects => true)
    assert(errors.empty?, errors.map{|e| e[:message] }.join("\n"))
  end

  def test_relative_definition
    schema = File.join(File.dirname(__FILE__),"schemas/relative_definition_schema.json")

    data = {"a" => "foo"}
    assert(!JSON::Validator.validate(schema,data))

    data = {"a" => 5}
    assert(JSON::Validator.validate(schema,data))
  end

end
