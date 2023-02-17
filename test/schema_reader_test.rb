require File.expand_path('../support/test_helper', __FILE__)

class SchemaReaderTest < Minitest::Test
  ADDRESS_SCHEMA_URI  = 'http://json-schema.org/address'
  ADDRESS_SCHEMA_PATH = File.expand_path('../schemas/address_microformat.json', __FILE__)

  def stub_address_request(body = File.read(ADDRESS_SCHEMA_PATH))
    stub_request(:get, ADDRESS_SCHEMA_URI)
      .to_return(body: body, status: 200)
  end

  def test_accept_all_uris
    stub_address_request

    reader = JSON::Schema::Reader.new
    schema = reader.read(ADDRESS_SCHEMA_URI)

    assert_equal schema.uri, Addressable::URI.parse("#{ADDRESS_SCHEMA_URI}#")
  end

  def test_accept_all_files
    reader = JSON::Schema::Reader.new
    schema = reader.read(ADDRESS_SCHEMA_PATH)

    assert_equal schema.uri, Addressable::URI.convert_path(ADDRESS_SCHEMA_PATH + '#')
  end

  def test_refuse_all_uris
    reader = JSON::Schema::Reader.new(accept_uri: false)
    refute reader.accept_uri?(Addressable::URI.parse('http://foo.com'))
  end

  def test_refuse_all_files
    reader = JSON::Schema::Reader.new(accept_file: false)
    refute reader.accept_file?(Pathname.new('/foo/bar/baz'))
  end

  def test_accept_uri_proc
    reader = JSON::Schema::Reader.new(
      accept_uri: proc { |uri| uri.host == 'json-schema.org' },
    )

    assert reader.accept_uri?(Addressable::URI.parse('http://json-schema.org/address'))
    refute reader.accept_uri?(Addressable::URI.parse('http://sub.json-schema.org/address'))
  end

  def test_accept_file_proc
    test_root = Pathname.new(__FILE__).expand_path.dirname

    reader = JSON::Schema::Reader.new(
      accept_file: proc { |path| path.to_s.start_with?(test_root.to_s) },
    )

    assert reader.accept_file?(test_root.join('anything.json'))
    refute reader.accept_file?(test_root.join('..', 'anything.json'))
  end

  def test_file_scheme
    reader = JSON::Schema::Reader.new(accept_uri: true, accept_file: false)
    error = assert_raises(JSON::Schema::ReadRefused) do
      reader.read('file://' + ADDRESS_SCHEMA_PATH)
    end

    assert_equal(:file, error.type)
    assert_equal(ADDRESS_SCHEMA_PATH, error.location)
    assert_equal("Read of file at #{ADDRESS_SCHEMA_PATH} refused", error.message)
  end

  def test_parse_error
    stub_address_request('this is totally not valid JSON!')

    reader = JSON::Schema::Reader.new

    assert_raises(JSON::Schema::JsonParseError) do
      reader.read(ADDRESS_SCHEMA_URI)
    end
  end
end
