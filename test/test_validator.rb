require File.expand_path('../test_helper', __FILE__)

class TestValidator < Minitest::Test

  class MockLoader
    def load(location)
      schema = {
        '$schema' => 'http://json-schema.org/draft-04/schema#',
        'type' => 'string',
        'minLength' => 2
      }

      JSON::Schema.new(schema, Addressable::URI.parse(location.to_s))
    end
  end

  def setup
    @original_loader = JSON::Validator.schema_loader
  end

  def teardown
    JSON::Validator.schema_loader = @original_loader
  end

  def test_default_schema_loader
    loader = JSON::Validator.schema_loader
    assert loader.accept_uri?(Addressable::URI.parse('http://example.com'))
    assert loader.accept_file?(Pathname.new('/etc/passwd'))
  end

  def test_set_default_schema_loader
    JSON::Validator.schema_loader = MockLoader.new

    schema = { '$ref' => 'http://any.url/at/all' }
    assert_valid schema, 'abc'
    refute_valid schema, 'a'
  end

  def test_validate_with_loader
    loader = MockLoader.new
    schema = { '$ref' => 'http://any.url/at/all' }
    assert_valid schema, 'abc', :schema_loader => loader
    refute_valid schema, 'a', :schema_loader => loader
  end

  def test_validate_list_with_loader
    loader = MockLoader.new
    schema = { '$ref' => 'http://what.ever/schema' }
    assert_valid schema, ['abc', 'def'], :schema_loader => loader, :list => true
    refute_valid schema, ['abc', 'a'], :schema_loader => loader, :list => true
  end

end
