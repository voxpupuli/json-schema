require File.expand_path('../test_helper', __FILE__)
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "array",
      "items" => { "$ref" => "../google.json"}
    }

    data = [1,2,3]
    assert_raises(Errno::ENOENT) do
      JSON::Validator.validate(schema,data)
    end
  end

  def test_bad_host_ref
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "array",
      "items" => { "$ref" => "http://ppcheesecheseunicornnuuuurrrrr.example.invalid/json.schema"}
    }

    data = [1,2,3]
    assert_raises(SocketError, OpenURI::HTTPError) do
      JSON::Validator.validate(schema,data)
    end
  end
end
