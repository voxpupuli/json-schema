module EnumValidation
  def test_enum
    schema = {
      "properties" => {
        "a" => {"enum" => [1,'boo',[1,2,3],{"a" => "b"}]}
      }
    }

    data = { "a" => 1 }
    assert_valid schema, data

    data["a"] = 'boo'
    assert_valid schema, data

    data["a"] = [1,2,3]
    assert_valid schema, data

    data["a"] = {"a" => "b"}
    assert_valid schema, data

    data["a"] = 'taco'
    refute_valid schema, data

    data = {}
    assert_valid schema, data
  end

  def test_fixed_float_issue_enum
    schema = {
      "properties" => {
        "a" => {
          "type" => "number",
          "enum" => [0, 1, 2]
        }
      }
    }

    data = { "a" => 0 }
    assert_valid schema, data

    data["a"] = 0.0
    assert_valid schema, data

    data["a"] = 1
    assert_valid schema, data

    data["a"] = 1.0
    assert_valid schema, data
  end

  def test_enum_with_schema_validation
    schema = {
      "properties" => {
        "a" => {"enum" => [1,'boo',[1,2,3],{"a" => "b"}]}
      }
    }
    data = { "a" => 1 }
    assert_valid(schema, data, :validate_schema => true)
  end

  module ItemsTests
    def test_items_single_schema
      schema = { 'items' => { 'type' => 'string' } }

      assert_valid schema, []
      assert_valid schema, ['a']
      assert_valid schema, ['a', 'b']

      refute_valid schema, [1]
      refute_valid schema, ['a', 1]

      # other types are disregarded
      assert_valid schema, {'a' => 'foo'}
    end
  end
end
