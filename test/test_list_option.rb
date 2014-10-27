require_relative 'test_helper'

class ListOptionTest < Test::Unit::TestCase
  def test_list_option_reusing_schemas
    schema_hash = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => { "a" => { "type" => "integer" } }
    }

    uri = URI.parse('http://example.com/item')
    schema = JSON::Schema.new(schema_hash, uri)
    JSON::Validator.add_schema(schema)

    data = {"a" => 1}
    assert(JSON::Validator.validate(uri.to_s, data))

    data = [{"a" => 1}]
    assert(JSON::Validator.validate(uri.to_s, data, :list => true))
  end
end
