require File.expand_path('../support/test_helper', __FILE__)

class InitializeDataTest < Minitest::Test

  def test_parse_character_string
    schema = {'type' => 'string'}
    data = 'hello world'

    assert(JSON::Validator.validate(schema, data))

    assert(JSON::Validator.validate(schema, data, :parse_data => false))

    assert_raises(JSON::Schema::JsonParseError) do
      JSON::Validator.validate(schema, data, :json => true)
    end

    assert_raises(JSON::Schema::JsonLoadError) { JSON::Validator.validate(schema, data, :uri => true) }
  end

  def test_parse_integer_string
    schema = {'type' => 'integer'}
    data = '42'

    assert(JSON::Validator.validate(schema, data))

    refute(JSON::Validator.validate(schema, data, :parse_data => false))

    assert(JSON::Validator.validate(schema, data, :json => true))

    assert_raises(JSON::Schema::JsonLoadError) { JSON::Validator.validate(schema, data, :uri => true) }
  end

  def test_parse_hash_string
    schema = { 'type' => 'object', 'properties' => { 'a' => { 'type' => 'string' } } }
    data = '{"a": "b"}'

    assert(JSON::Validator.validate(schema, data))

    refute(JSON::Validator.validate(schema, data, :parse_data => false))

    assert(JSON::Validator.validate(schema, data, :json => true))

    assert_raises(JSON::Schema::UriError) { JSON::Validator.validate(schema, data, :uri => true) }
  end

  def test_parse_json_string
    schema = {'type' => 'string'}
    data = '"hello world"'

    assert(JSON::Validator.validate(schema, data))

    assert(JSON::Validator.validate(schema, data, :parse_data => false))

    assert(JSON::Validator.validate(schema, data, :json => true))

    assert_raises(JSON::Schema::JsonLoadError) { JSON::Validator.validate(schema, data, :uri => true) }
  end

  def test_parse_valid_uri_string
    schema = {'type' => 'string'}
    data = 'http://foo.bar/'

    stub_request(:get, "foo.bar").to_return(:body => '"hello world"', :status => 200)

    assert(JSON::Validator.validate(schema, data))

    assert(JSON::Validator.validate(schema, data, :parse_data => false))

    assert_raises(JSON::Schema::JsonParseError) do
      JSON::Validator.validate(schema, data, :json => true)
    end

    assert(JSON::Validator.validate(schema, data, :uri => true))
  end

  def test_parse_invalid_uri_string
    schema = {'type' => 'string'}
    data = 'http://foo.bar/'

    stub_request(:get, "foo.bar").to_timeout

    assert(JSON::Validator.validate(schema, data))

    assert(JSON::Validator.validate(schema, data, :parse_data => false))

    stub_request(:get, "foo.bar").to_return(:status => [500, "Internal Server Error"])

    assert(JSON::Validator.validate(schema, data))

    assert(JSON::Validator.validate(schema, data, :parse_data => false))

    assert_raises(JSON::Schema::JsonParseError) do
      JSON::Validator.validate(schema, data, :json => true)
    end

    assert_raises(JSON::Schema::JsonLoadError) { JSON::Validator.validate(schema, data, :uri => true) }
  end

  def test_parse_integer
    schema = {'type' => 'integer'}
    data = 42

    assert(JSON::Validator.validate(schema, data))

    assert(JSON::Validator.validate(schema, data, :parse_data => false))

    assert_raises(TypeError) { JSON::Validator.validate(schema, data, :json => true) }

    assert_raises(TypeError) { JSON::Validator.validate(schema, data, :uri => true) }
  end

  def test_parse_hash
    schema = { 'type' => 'object', 'properties' => { 'a' => { 'type' => 'string' } } }
    data = { 'a' => 'b' }

    assert(JSON::Validator.validate(schema, data))

    assert(JSON::Validator.validate(schema, data, :parse_data => false))

    assert_raises(TypeError) { JSON::Validator.validate(schema, data, :json => true) }

    assert_raises(TypeError) { JSON::Validator.validate(schema, data, :uri => true) }
  end
end
