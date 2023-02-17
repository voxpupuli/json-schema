require File.expand_path('../support/test_helper', __FILE__)

class StringifyTest < Minitest::Test
  def test_stringify_on_hash
    hash = {
      :a => 'foo',
      'b' => :bar,
    }
    assert_equal({ 'a' => 'foo', 'b' => 'bar' }, JSON::Schema.stringify(hash), 'symbol keys should be converted to strings')
  end

  def test_stringify_on_array
    array = [
      :a,
      'b',
    ]
    assert_equal(%w[a b], JSON::Schema.stringify(array), 'symbols in an array should be converted to strings')
  end

  def test_stringify_on_hash_of_arrays
    hash = {
      :a => [:foo],
      'b' => :bar,
    }
    assert_equal({ 'a' => ['foo'], 'b' => 'bar' }, JSON::Schema.stringify(hash), 'symbols in a nested array should be converted to strings')
  end

  def test_stringify_on_array_of_hashes
    array = [
      :a,
      {
        b: :bar,
      },
    ]
    assert_equal(['a', { 'b' => 'bar' }], JSON::Schema.stringify(array), 'symbols keys in a nested hash should be converted to strings')
  end

  def test_stringify_on_hash_of_hashes
    hash = {
      a: {
        b: {
          foo: :bar,
        },
      },
    }
    assert_equal({ 'a' => { 'b' => { 'foo' => 'bar' } } }, JSON::Schema.stringify(hash), 'symbols in a nested hash of hashes should be converted to strings')
  end
end
