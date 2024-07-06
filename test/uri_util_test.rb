require File.expand_path('../support/test_helper', __FILE__)

class UriUtilTest < Minitest::Test
  def populate_cache_with(str, &blk)
    cached_uri = Addressable::URI.parse(str)
    Addressable::URI.stub(:parse, cached_uri, &blk)
    cached_uri
  end

  def teardown
    JSON::Util::URI.clear_cache
  end

  def test_uri_parse
    str = 'https://www.google.com/search'
    uri = Addressable::URI.new(scheme: 'https',
                               host: 'www.google.com',
                               path: 'search',)
    assert_equal uri, JSON::Util::URI.parse(str)
  end

  def test_invalid_uri_parse
    uri = ':::::::'
    assert_raises(JSON::Schema::UriError) do
      JSON::Util::URI.parse(uri)
    end
  end

  def test_parse_cache
    cached_uri = populate_cache_with('www.google.com') do
      JSON::Util::URI.parse('foo')
    end

    assert_equal(cached_uri, JSON::Util::URI.parse('foo'))

    JSON::Util::URI.clear_cache

    refute_equal(cached_uri, JSON::Util::URI.parse('foo'))
  end

  def test_validator_clear_cache_for_parse
    cached_uri = populate_cache_with('www.google.com') do
      JSON::Util::URI.parse('foo')
    end

    assert_equal(cached_uri, JSON::Util::URI.parse('foo'))

    validation_errors({ 'type' => 'string' }, 'foo', clear_cache: true)

    refute_equal(cached_uri, JSON::Util::URI.parse('foo'))
  end
end
