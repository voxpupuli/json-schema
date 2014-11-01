require File.expand_path('../test_helper', __FILE__)

class OneOfTest < Minitest::Test
  def test_one_of_links_schema
    schema = schema_fixture_path('one_of_ref_links_schema.json')
    data   = data_fixture_path('one_of_ref_links_data.json')
    assert_valid schema, data
  end

  def test_one_of_with_string_patterns
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "oneOf" => [
        {
          "properties" => {"a" => {"type" => "string", "pattern" => "foo"}},
        },
        {
          "properties" => {"a" => {"type" => "string", "pattern" => "bar"}},
        },
        {
          "properties" => {"a" => {"type" => "string", "pattern" => "baz"}},
        }
      ]
    }

    assert_valid schema, { "a" => "foo" }
    refute_valid schema, { "a" => "foobar" }
    assert_valid schema, { "a" => "baz" }
    refute_valid schema, { "a" => 5 }
  end

end
