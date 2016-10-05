# coding: utf-8
require File.expand_path('../support/test_helper', __FILE__)

class UriParsingTest < Minitest::Test
  def populate_cache_with(str, &blk)
    cached_uri = Addressable::URI.parse(str)
    Addressable::URI.stub(:parse, cached_uri, &blk)
    cached_uri
  end

  def teardown
    JSON::Util::URI.clear_cache
  end

  def test_asian_characters
    schema = {
      "$schema"=> "http://json-schema.org/draft-04/schema#",
      "id"=> "http://俺:鍵@例え.テスト/p?条件#ここ#",
      "type" => "object",
      "required" => ["a"],
      "properties" => {
        "a" => {
          "id" => "a",
          "type" => "integer"
        }
      }
    }
    data = { "a" => 5 }
    assert_valid schema, data
  end

  def test_schema_ref_with_empty_fragment
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "required" => ["names"],
      "properties"=> {
        "names"=> {
          "type"=> "array",
          "items"=> {
            "anyOf"=> [
              { "$ref" => "test/schemas/ref john with spaces schema.json#" },
            ]
          }
        }
      }
    }
    data = {"names" => [{"first" => "john"}]}
    assert_valid schema, data
  end

  def test_schema_ref_from_file_with_spaces
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "required" => ["names"],
      "properties"=> {
        "names"=> {
          "type"=> "array",
          "items"=> {
            "anyOf"=> [
              { "$ref" => "test/schemas/ref john with spaces schema.json" }
            ]
          }
        }
      }
    }
    data = {"names" => [{"first" => "john"}]}
    assert_valid schema, data
  end

  def test_schema_from_file_with_spaces
    data = {"first" => "john"}
    schema = "test/schemas/ref john with spaces schema.json"
    assert_valid schema, data
  end

  def test_normalized_uri
    str = "https://www.google.com/search"
    uri = Addressable::URI.new(scheme: 'https',
                               host: 'www.google.com',
                               path: 'search')
    assert_equal uri, JSON::Util::URI.normalized_uri(str, '/home')
  end

  def test_normalized_uri_with_empty_fragment
    str = "https://www.google.com/search#"
    uri = Addressable::URI.new(scheme: 'https',
                               host: 'www.google.com',
                               path: 'search',
                               fragment: nil)
    assert_equal uri, JSON::Util::URI.normalized_uri(str, '/home')
  end

  def test_normalized_uri_with_fragment
    str = "https://www.google.com/search#foo"
    uri = Addressable::URI.new(scheme: 'https',
                               host: 'www.google.com',
                               path: 'search',
                               fragment: 'foo')
    assert_equal uri, JSON::Util::URI.normalized_uri(str, '/home')
  end

  def test_normalized_uri_for_absolute_path
    str = "/foo/bar.json"
    uri = Addressable::URI.new(scheme: 'file',
                               path: '///foo/bar.json')
    assert_equal uri, JSON::Util::URI.normalized_uri(str, '/home')
  end

  def test_normalized_uri_for_relartive_path
    str = "foo/bar.json"
    uri = Addressable::URI.new(scheme: 'file',
                               path: '///home/foo/bar.json')
    assert_equal uri, JSON::Util::URI.normalized_uri(str, '/home')
  end

  def test_uri_parse
    str = "https://www.google.com/search"
    uri = Addressable::URI.new(scheme: 'https',
                               host: 'www.google.com',
                               path: 'search')
    assert_equal uri, JSON::Util::URI.parse(str)
  end

  def test_invalid_uri_parse
    uri = ":::::::"
    assert_raises(JSON::Schema::UriError) do
      JSON::Util::URI.parse(uri)
    end
  end

  def test_normalization_cache
    cached_uri = populate_cache_with('www.google.com') do
      JSON::Util::URI.normalized_uri('foo')
    end

    assert_equal(cached_uri, JSON::Util::URI.normalized_uri('foo'))

    JSON::Util::URI.clear_cache

    refute_equal(cached_uri, JSON::Util::URI.normalized_uri('foo'))
  end

  def test_parse_cache
    cached_uri = populate_cache_with('www.google.com') do
      JSON::Util::URI.parse('foo')
    end

    assert_equal(cached_uri, JSON::Util::URI.parse('foo'))

    JSON::Util::URI.clear_cache

    refute_equal(cached_uri, JSON::Util::URI.parse('foo'))
  end

  def test_validator_clear_cache_for_normalized_uri
    cached_uri = populate_cache_with('www.google.com') do
      JSON::Util::URI.normalized_uri('foo')
    end

    assert_equal(cached_uri, JSON::Util::URI.normalized_uri('foo'))

    validation_errors({"type" => "string"}, "foo", :clear_cache => true)

    refute_equal(cached_uri, JSON::Util::URI.normalized_uri('foo'))
  end

  def test_validator_clear_cache_for_parse
    cached_uri = populate_cache_with('www.google.com') do
      JSON::Util::URI.parse('foo')
    end

    assert_equal(cached_uri, JSON::Util::URI.parse('foo'))

    validation_errors({"type" => "string"}, "foo", :clear_cache => true)

    refute_equal(cached_uri, JSON::Util::URI.parse('foo'))
  end
end
