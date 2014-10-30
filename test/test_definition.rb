require File.expand_path('../test_helper', __FILE__)

class RelativeDefinitionTest < MiniTest::Unit::TestCase

  def test_definition_schema
    assert_valid schema_fixture_path('definition_schema.json'), {"a" => 5}
  end

  def test_relative_definition
    schema = schema_fixture_path('relative_definition_schema.json')
    assert_valid schema, {"a" => 5}
    refute_valid schema, {"a" => "foo"}
  end

end
