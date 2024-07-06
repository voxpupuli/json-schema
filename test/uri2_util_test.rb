require File.expand_path('../support/test_helper', __FILE__)

class Uri2UtilTest < Minitest::Test
  def test_normalized_uri
    str = 'https://www.google.com/search'
    uri = Addressable::URI.new(scheme: 'https',
                               host: 'www.google.com',
                               path: 'search',)
    assert_equal uri, JSON::Util::URI2.normalize_uri(str, '/home')
  end

  def test_normalized_uri_with_empty_fragment
    str = 'https://www.google.com/search#'
    uri = Addressable::URI.new(scheme: 'https',
                               host: 'www.google.com',
                               path: 'search',
                               fragment: nil,)
    assert_equal uri, JSON::Util::URI2.normalize_uri(str, '/home')
  end

  def test_normalized_uri_with_fragment
    str = 'https://www.google.com/search#foo'
    uri = Addressable::URI.new(scheme: 'https',
                               host: 'www.google.com',
                               path: 'search',
                               fragment: 'foo',)
    assert_equal uri, JSON::Util::URI2.normalize_uri(str, '/home')
  end

  def test_normalized_uri_for_absolute_path
    str = '/foo/bar.json'
    uri = Addressable::URI.new(scheme: 'file',
                               host: '',
                               path: '/foo/bar.json',)
    assert_equal uri, JSON::Util::URI2.normalize_uri(str, '/home')
  end

  def test_normalized_uri_for_relative_path
    str = 'foo/bar.json'
    uri = Addressable::URI.new(scheme: 'file',
                               host: '',
                               path: '/home/foo/bar.json',)
    assert_equal uri, JSON::Util::URI2.normalize_uri(str, '/home')
  end

  def test_normalized_uri_for_file_path_with_host
    str = 'file://localhost/foo/bar.json'
    uri = Addressable::URI.new(scheme: 'file',
                               host: 'localhost',
                               path: '/foo/bar.json',)
    assert_equal uri, JSON::Util::URI2.normalize_uri(str, '/home')
  end
end
