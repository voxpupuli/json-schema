require File.expand_path('../support/test_helper', __FILE__)

class CachingTestTest < Minitest::Test
  URI = "http://example.com/test-schema.json"

  def test_caching
    initial_schema = {
      "type" => "string"
    }
    schema = JSON::Schema.new(initial_schema, URI)
    JSON::Validator.add_schema(schema)
    assert_valid(URI, "foo", :clear_cache => false)

    initial_schema = {
      "type" => "number"
    }
    schema = JSON::Schema.new(initial_schema, URI)
    JSON::Validator.add_schema(schema)
    assert_valid(URI, "foo")
  end

  def test_clear_cache
    initial_schema = {
      "type" => "string"
    }
    schema = JSON::Schema.new(initial_schema, URI)
    JSON::Validator.add_schema(schema)
    assert_valid(URI, "foo", :clear_cache => true)

    initial_schema = {
      "type" => "number"
    }
    schema = JSON::Schema.new(initial_schema, URI)
    JSON::Validator.add_schema(schema)
    assert_valid(URI, 123)
  end

  def test_cache_schemas
    suppress_warnings do
      JSON::Validator.cache_schemas = true
    end

    initial_schema = {
      "type" => "string"
    }
    schema = JSON::Schema.new(initial_schema, URI)
    JSON::Validator.add_schema(schema)
    assert_valid(URI, "foo")

    initial_schema = {
      "type" => "number"
    }
    schema = JSON::Schema.new(initial_schema, URI)
    JSON::Validator.add_schema(schema)
    assert_valid(URI, 123)
  ensure
    suppress_warnings do
      JSON::Validator.cache_schemas = false
    end
  end
end
