require File.expand_path('support/test_helper', __dir__)

class MinItemsTest < Minitest::Test
  def test_minitems_nils
    schema = {
      'type' => 'array',
      'minItems' => 1,
      'items' => { 'type' => 'object' },
    }

    errors = JSON::Validator.fully_validate(schema, [nil])

    assert_equal(1, errors.length)
    refute_match(/minimum/, errors[0])
    assert_match(/null/, errors[0])
  end
end
