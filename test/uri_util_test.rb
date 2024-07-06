require File.expand_path('../support/test_helper', __FILE__)

class UriUtilTest < Minitest::Test
  def populate_cache_with(str, &blk)
    cached_uri = Addressable::URI.parse(str)
    Addressable::URI.stub(:parse, cached_uri, &blk)
    cached_uri
  end

  def test_uri_parse
    str = 'https://www.google.com/search'
    uri = Addressable::URI.new(scheme: 'https',
                               host: 'www.google.com',
                               path: 'search',)
    assert_equal uri, JSON::Util::URI2.parse(str)
  end

  def test_invalid_uri_parse
    uri = ':::::::'
    assert_raises(JSON::Schema::UriError) do
      JSON::Util::URI2.parse(uri)
    end
  end
end
