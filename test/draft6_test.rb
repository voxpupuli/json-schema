# encoding: utf-8
require File.expand_path('../support/test_helper', __FILE__)

class Draft6Test < Minitest::Test
  def validation_errors(schema, data, options)
    super(schema, data, :version => :draft6)
  end

  def test_const_attribute
    schema = {
      "type" => "object",
      "properties" => {
        "a" => {"const" => "foo"},
        "b" => {"const" => 6},
      }
    }

    data = {:a => "foo", :b => 6}
    assert_valid schema, data

    data = {:a => 6, :b => "foo"}
    refute_valid schema, data
  end
end
