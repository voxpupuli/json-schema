require File.expand_path('../support/test_helper', __FILE__)

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

  def test_merge_missing_values_for_empty_hash
    original = {}
    updated = {}
    JSON::Validator.merge_missing_values(updated, original)
    assert_equal({}, original)
  end

  def test_merge_missing_values_for_new_values
    original = { hello: 'world' }
    updated = { 'hello' => 'world', 'foo' => 'bar' }
    JSON::Validator.merge_missing_values(updated, original)
    assert_equal({ :hello => 'world', 'foo' => 'bar' }, original)
  end

  def test_merge_missing_values_for_nested_array
    original = [:hello, 'world', 1, 2, 3, { :foo => :bar, 'baz' => 'qux' }]
    updated = ['hello', 'world', 1, 2, 3, { 'foo' => 'bar', 'baz' => 'qux', 'this_is' => 'new' }]
    JSON::Validator.merge_missing_values(updated, original)
    assert_equal([:hello, 'world', 1, 2, 3, { :foo => :bar, 'baz' => 'qux', 'this_is' => 'new' }], original)
  end

  def test_merge_missing_values_for_nested_hash
    original = { hello: 'world', foo: ['bar', :baz, { uno: { due: 3 } }] }
    updated = { 'hello' => 'world', 'foo' => ['bar', 'baz', { 'uno' => { 'due' => 3, 'this_is' => 'new' } }], 'ack' => 'sed' }
    JSON::Validator.merge_missing_values(updated, original)
    assert_equal({ :hello => 'world', :foo => ['bar', :baz, { uno: { :due => 3, 'this_is' => 'new' } }], 'ack' => 'sed' }, original)
  end
end
