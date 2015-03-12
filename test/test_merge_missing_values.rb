require File.expand_path('../test_helper', __FILE__)

class MergeMissingValuesTest < Minitest::Test
  def test_merge_missing_values_for_string
    original = 'foo'
    updated = 'foo'
    JSON::Validator.merge_missing_values(updated, original)
    assert_equal('foo', original)
  end

  def test_merge_missing_values_for_empty_array
    original = []
    updated = []
    JSON::Validator.merge_missing_values(updated, original)
    assert_equal([], original)
  end

  def test_merge_not_changing_array_values
    original = [1, 'a', true]
    updated = [false, 7, :b, 'z']
    JSON::Validator.merge_missing_values(updated, original)
    assert_equal([1, 'a', true], original)
  end

  def test_merge_missing_values_for_empty_hash
    original = {}
    updated = {}
    JSON::Validator.merge_missing_values(updated, original)
    assert_equal({}, original)
  end

  def test_merge_missing_values_not_changing_hash_values
    original = {'a' => :b}
    updated = {'a' => 'b'}
    JSON::Validator.merge_missing_values(updated, original)
    assert_equal({'a' => :b}, original)
  end

  def test_merge_missing_values_for_new_values
    original = {'hello' => 'world'}
    updated = {'hello' => 'world', 'foo' => 'bar'}
    JSON::Validator.merge_missing_values(updated, original)
    assert_equal({'hello' => 'world', 'foo' => 'bar'}, original)
  end

  def test_merge_missing_values_for_nested_array
    original = ['hello', 'world', 1, 2, 3, {'foo' => 'bar', 'baz' => 'qux'}]
    updated = ['hello', 'world', 1, 2, 3, {'foo' => 'bar', 'baz' => 'qux', 'this_is' => 'new'}]
    JSON::Validator.merge_missing_values(updated, original)
    assert_equal(['hello', 'world', 1, 2, 3, {'foo' => 'bar', 'baz' => 'qux', 'this_is' => 'new'}], original)
  end

  def test_merge_missing_values_for_nested_hash
    original = {'hello' => 'world', 'foo' => ['bar', 'baz', {'uno' => {'due' => 3}}]}
    updated = {'hello' => 'world', 'foo' => ['bar', 'baz', {'uno' => {'due' => 3, 'this_is' => 'new'}}], 'ack' => 'sed'}
    JSON::Validator.merge_missing_values(updated, original)
    assert_equal({'hello' => 'world', 'foo' => ['bar', 'baz', {'uno' => {'due' => 3, 'this_is' => 'new'}}], 'ack' => 'sed'}, original)
  end

  def test_merge_missing_values_for_new_values_distinguish_symbol
    original = {:hello => 'world'}
    updated = {'hello' => 'world', 'foo' => 'bar'}
    JSON::Validator.merge_missing_values(updated, original)
    assert_equal({:hello => 'world', 'hello' => 'world', 'foo' => 'bar'}, original)
  end

  def test_merge_missing_values_for_nested_array_distinguish_symbol
    original = [:hello, 'world', 1, 2, 3, {:foo => :bar, 'baz' => 'qux'}]
    updated = ['hello', 'world', 1, 2, 3, {'foo' => 'bar', 'baz' => 'qux', 'this_is' => 'new'}]
    JSON::Validator.merge_missing_values(updated, original)
    assert_equal([:hello, 'world', 1, 2, 3, {:foo => :bar, 'foo' => 'bar', 'baz' => 'qux', 'this_is' => 'new'}], original)
  end

  def test_merge_missing_values_for_nested_hash_distinguish_symbol
    original = {:hello => 'world', 'foo' => ['bar', :baz, {'uno' => {:due => 3}}]}
    updated = {'hello' => 'world', 'foo' => ['bar', 'baz', {'uno' => {'due' => 3, 'this_is' => 'new'}}], 'ack' => 'sed'}
    JSON::Validator.merge_missing_values(updated, original)
    assert_equal({:hello => 'world', 'hello' => 'world', 'foo' => ['bar', :baz, {'uno' => {:due => 3, 'due' => 3, 'this_is' => 'new'}}], 'ack' => 'sed'}, original)
  end
end
