require_relative 'test_helper'

class MinItemsTest < Test::Unit::TestCase
  def test_minitems_nils
    schema = {
      "type" => "array",
      "minItems" => 1,
      "items" => { "type" => "object" }
    }

    errors = JSON::Validator.fully_validate(schema, [nil])
    assert_equal(errors.length, 1)
    assert(errors[0] !~ /minimum/)
    assert(errors[0] =~ /NilClass/)
  end
end
