require File.expand_path('../test_helper', __FILE__)

class StringifyInPlaceTest < Minitest::Test
  def test_stringify_in_place_on_hash
    hash = {
      :a => 'foo',
      'b' => :bar
    }
    JSON::Schema.stringify!(hash)
    assert_equal({'a' => 'foo', 'b' => 'bar'}, hash, 'symbol keys should be converted to strings')
  end

  def test_stringify_in_place_on_array
    array = [
      :a,
      'b'
    ]
    JSON::Schema.stringify!(array)
    assert_equal(['a', 'b'], array, 'symbols in an array should be converted to strings')
  end

  def test_stringify_in_place_on_hash_of_arrays
    hash = {
      :a => [:foo],
      'b' => :bar
    }
    JSON::Schema.stringify!(hash)
    assert_equal({'a' => ['foo'], 'b' => 'bar'}, hash, 'symbols in a nested array should be converted to strings')
  end

  def test_stringify_in_place_on_array_of_hashes
    array = [
      :a,
      {
        :b => :bar
      }
    ]
    JSON::Schema.stringify!(array)
    assert_equal(['a', {'b' => 'bar'}], array, 'symbols keys in a nested hash should be converted to strings')
  end

  def test_stringify_in_place_on_hash_of_hashes
    hash = {
      :a => {
        :b => {
          :foo => :bar
        }
      }
    }
    JSON::Schema.stringify!(hash)
    assert_equal({'a' => {'b' => {'foo' => 'bar'} } }, hash, 'symbols in a nested hash of hashes should be converted to strings')
  end
end
