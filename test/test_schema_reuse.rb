require File.expand_path('../test_helper', __FILE__)

class SchemaReuseTest < Minitest::Test
  def test_validate_schema_with_schema_object
    schema = JSON::Schema.new({ 'type' => 'array' }, URI.parse('http://example.com/array'))

    assert_valid schema, []
    assert JSON::Validator.schemas.key?('http://example.com/array#')

    refute_valid schema, {}
  end
end
