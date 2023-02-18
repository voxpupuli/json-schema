require File.expand_path('../support/test_helper', __FILE__)

class MinItemsTest < Minitest::Test
  def test_minitems_nils
    schema = {
      'type' => 'array',
      'minItems' => 1,
      'items' => { 'type' => 'object' },
    }

    errors = JSON::Validator.fully_validate(schema, [nil])

    assert_equal(1, errors.length)
    assert(errors[0] !~ /minimum/)
    assert(errors[0] =~ /null/)
  end
end
