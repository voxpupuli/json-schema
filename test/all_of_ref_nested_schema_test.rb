require File.expand_path('support/test_helper', __dir__)

class AllOfRefNestedSchemaTest < Minitest::Test
  def schema
    schema_fixture_path('all_of_ref_nested_schema.json')
  end

  def test_valid_nested_schema
    data = {
      nested: {
        a: 'valueA',
        b: 'valueB',
        c: 'valueC',
      },
    }

    assert_valid schema, data, { noAdditionalProperties: true }
  end

  def test_invalid_nested_schema
    data = {
      nested: {
        a: 'valueA',
        c: 'valueC',
      },
    }

    refute_valid schema, data, { noAdditionalProperties: true }
  end
end
