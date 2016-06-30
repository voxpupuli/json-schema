require File.expand_path('../support/test_helper', __FILE__)

class UriUtilTest < Minitest::Test
  def test_fake_uri_is_unique
    refute_equal JSON::Util::URI.fake_uri('foo'), JSON::Util::URI.fake_uri('bar')
  end

  def test_fake_uri_is_reproducible
    assert_equal JSON::Util::URI.fake_uri('foo'), JSON::Util::URI.fake_uri('foo')
  end
end
