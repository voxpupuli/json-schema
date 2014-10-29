require_relative 'test_helper'

class TestSchemaTypeAttribute < Test::Unit::TestCase
  def test_type_of_data
    assert_equal(type_of_data(String.new), 'string')
    assert_equal(type_of_data(Numeric.new), 'number')
    assert_equal(type_of_data(1), 'integer')
    assert_equal(type_of_data(true), 'boolean')
    assert_equal(type_of_data(false), 'boolean')
    assert_equal(type_of_data(Hash.new), 'object')
    assert_equal(type_of_data(nil), 'null')
    assert_equal(type_of_data(Object.new), 'any')
  end

  private

  def type_of_data(data)
    JSON::Schema::TypeAttribute.type_of_data(data)
  end
end
