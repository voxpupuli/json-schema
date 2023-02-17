require File.expand_path('../support/test_helper', __FILE__)

class CachingTestTest < Minitest::Test
  def setup
    @schema = Tempfile.new(['schema', '.json'])
  end

  def teardown
    @schema.close
    @schema.unlink

    JSON::Validator.clear_cache
  end

  def test_caching
    set_schema('type' => 'string')
    assert_valid(schema_path, 'foo', clear_cache: false)

    set_schema('type' => 'number')
    refute_valid(schema_path, 123)
  end

  def test_clear_cache
    set_schema('type' => 'string')
    assert_valid(schema_path, 'foo', clear_cache: true)

    set_schema('type' => 'number')
    assert_valid(schema_path, 123)
  end

  def test_cache_schemas
    suppress_warnings do
      JSON::Validator.cache_schemas = false
    end

    set_schema('type' => 'string')
    assert_valid(schema_path, 'foo', clear_cache: false)

    set_schema('type' => 'number')
    assert_valid(schema_path, 123)
  ensure
    suppress_warnings do
      JSON::Validator.cache_schemas = true
    end
  end

  private

  def schema_path
    @schema.path
  end

  def set_schema(schema_definition)
    @schema.write(schema_definition.to_json)
    @schema.rewind
  end
end
