require File.expand_path('../support/test_helper', __FILE__)
require 'json-schema/pointer'

class JsonSchemaPointerTest < Minitest::Test
  def test_initialize_parsing_fragment
    pointer = JSON::Schema::Pointer.new(:fragment, "#/a%2520%20b/c~1d/e%7E0f/0")

    assert_equal(['a%20 b', 'c/d', 'e~f', '0'], pointer.reference_tokens)
  end
  def test_initialize_parsing_pointer
    pointer = JSON::Schema::Pointer.new(:pointer, "/a%20 b/c~1d/e~0f/0")

    assert_equal(['a%20 b', 'c/d', 'e~f', '0'], pointer.reference_tokens)
  end
  def test_initialize_reference_tokens
    pointer = JSON::Schema::Pointer.new(:reference_tokens, ['a%20 b', 'c/d', 'e~f', '0'])

    assert_equal(['a%20 b', 'c/d', 'e~f', '0'], pointer.reference_tokens)
  end
  def test_initialize_bad_fragment
    assert_raises(JSON::Schema::Pointer::PointerSyntaxError) do
      JSON::Schema::Pointer.new(:fragment, "a%2520%20b/c~1d/e%7E0f/0")
    end
  end
  def test_initialize_bad_pointer
    assert_raises(JSON::Schema::Pointer::PointerSyntaxError) do
      JSON::Schema::Pointer.new(:pointer, "a%20 b/c~1d/e~0f/0")
    end
  end
  def test_evaluate_success
    pointer = JSON::Schema::Pointer.new(:fragment, "#/a%2520%20b/c~1d/e%7E0f/0")
    assert_equal(1, pointer.evaluate({'a%20 b' => {'c/d' => {'e~f' => [1]}}}))
  end
  def test_evaluate_empty_strings_success
    pointer = JSON::Schema::Pointer.new(:fragment, "#/a///0//")
    assert_equal(1, pointer.evaluate({'a' => {'' => {'' => [{'' => {'' => 1}}]}}}))
  end
  def test_evaluate_fail
    assert_raises(JSON::Schema::Pointer::ReferenceError) do
      pointer = JSON::Schema::Pointer.new(:fragment, "#/a%2520%20b/c~1d/e%7E0f/0")
      pointer.evaluate([])
    end
  end
end
