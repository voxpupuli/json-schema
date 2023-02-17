require File.expand_path('../support/test_helper', __FILE__)
require 'socket'

class BadSchemaRefTest < Minitest::Test
  def setup
    WebMock.allow_net_connect!
  end

  def teardown
    WebMock.disable_net_connect!
  end

  def test_bad_uri_ref
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'array',
      'items' => { '$ref' => '../google.json' },
    }

    data = [1, 2, 3]
    error = assert_raises(JSON::Schema::ReadFailed) do
      JSON::Validator.validate(schema, data)
    end

    expanded_path = File.expand_path('../../google.json', __FILE__)

    assert_equal(:file, error.type)
    assert_equal(expanded_path, error.location)
    assert_equal("Read of file at #{expanded_path} failed", error.message)
  end

  def test_bad_host_ref
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'array',
      'items' => { '$ref' => 'http://ppcheesecheseunicornnuuuurrrrr.example.invalid/json.schema' },
    }

    data = [1, 2, 3]
    error = assert_raises(JSON::Schema::ReadFailed) do
      JSON::Validator.validate(schema, data)
    end

    assert_equal(:uri, error.type)
    assert_equal('http://ppcheesecheseunicornnuuuurrrrr.example.invalid/json.schema', error.location)
    assert_equal('Read of URI at http://ppcheesecheseunicornnuuuurrrrr.example.invalid/json.schema failed', error.message)
  end
end
