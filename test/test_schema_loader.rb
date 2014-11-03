require File.expand_path('../test_helper', __FILE__)
require 'webmock'

class TestSchemaLoader < Minitest::Test
  ADDRESS_SCHEMA_URI  = 'http://json-schema.org/address'
  ADDRESS_SCHEMA_PATH = File.expand_path('../schemas/address_microformat.json', __FILE__)

  include WebMock::API

  def setup
    WebMock.enable!
    WebMock.disable_net_connect!
  end

  def teardown
    WebMock.reset!
    WebMock.disable!
  end

  def stub_address_request(body = File.read(ADDRESS_SCHEMA_PATH))
    stub_request(:get, ADDRESS_SCHEMA_URI).
      to_return(:body => body, :status => 200)
  end

  def test_accept_all_uris
    stub_address_request

    loader = JSON::Schema::Loader.new
    schema = loader.load(ADDRESS_SCHEMA_URI)

    assert_equal schema.uri, Addressable::URI.parse("#{ADDRESS_SCHEMA_URI}#")
  end

  def test_accept_all_files
    loader = JSON::Schema::Loader.new
    schema = loader.load(ADDRESS_SCHEMA_PATH)

    assert_equal schema.uri, Addressable::URI.convert_path(ADDRESS_SCHEMA_PATH + '#')
  end

  def test_refuse_all_uris
    loader = JSON::Schema::Loader.new(:accept_uri => false)
    refute loader.accept_uri?(Addressable::URI.parse('http://foo.com'))
  end

  def test_refuse_all_files
    loader = JSON::Schema::Loader.new(:accept_file => false)
    refute loader.accept_file?(Pathname.new('/foo/bar/baz'))
  end

  def test_accept_uri_proc
    loader = JSON::Schema::Loader.new(
      :accept_uri => proc { |uri| uri.host == 'json-schema.org' }
    )

    assert loader.accept_uri?(Addressable::URI.parse('http://json-schema.org/address'))
    refute loader.accept_uri?(Addressable::URI.parse('http://sub.json-schema.org/address'))
  end

  def test_accept_file_proc
    test_root = Pathname.new(__FILE__).expand_path.dirname

    loader = JSON::Schema::Loader.new(
      :accept_file => proc { |path| path.to_s.start_with?(test_root.to_s) }
    )

    assert loader.accept_file?(test_root.join('anything.json'))
    refute loader.accept_file?(test_root.join('..', 'anything.json'))
  end

  def test_file_scheme
    loader = JSON::Schema::Loader.new(:accept_uri => true, :accept_file => false)
    assert_raises(JSON::Schema::LoadRefused) do
      loader.load('file://' + ADDRESS_SCHEMA_PATH)
    end
  end

  def test_parse_error
    stub_address_request('this is totally not valid JSON!')

    loader = JSON::Schema::Loader.new
    assert_raises(JSON::ParserError) do
      loader.load(ADDRESS_SCHEMA_URI)
    end
  end
end
