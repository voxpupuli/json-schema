require File.expand_path('support/test_helper', __dir__)

class TypeAttributeTest < Minitest::Test
  def test_type_of_data
    assert_equal('string', type_of_data(''))
    assert_equal('number', type_of_data(Numeric.new))
    assert_equal('integer', type_of_data(1))
    assert_equal('boolean', type_of_data(true))
    assert_equal('boolean', type_of_data(false))
    assert_equal('object', type_of_data({}))
    assert_equal('null', type_of_data(nil))
    assert_equal('any', type_of_data(Object.new))
  end

  private

  def type_of_data(data)
    JSON::Schema::TypeAttribute.type_of_data(data)
  end
end
