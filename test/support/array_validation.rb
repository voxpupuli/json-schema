module ArrayValidation
  module ItemsTests
    def test_items_single_schema
      schema = { 'items' => { 'type' => 'string' } }

      assert_valid schema, []
      assert_valid schema, ['a']
      assert_valid schema, %w[a b]

      refute_valid schema, [1]
      refute_valid schema, ['a', 1]

      # other types are disregarded
      assert_valid schema, { 'a' => 'foo' }
    end

    def test_items_multiple_schemas
      schema = {
        'items' => [
          { 'type' => 'string' },
          { 'type' => 'integer' },
        ],
      }

      assert_valid schema, ['b', 1]
      assert_valid schema, ['b', 1, nil]
      refute_valid schema, [1, 'b']
      assert_valid schema, []
      assert_valid schema, ['b']
      assert_valid schema, ['b', 1, 25]
    end

    def test_minitems
      schema = { 'minItems' => 1 }

      assert_valid schema, [1]
      assert_valid schema, [1, 2]
      refute_valid schema, []

      # other types are disregarded
      assert_valid schema, 5
    end

    def test_maxitems
      schema = { 'maxItems' => 1 }

      assert_valid schema, []
      assert_valid schema, [1]
      refute_valid schema, [1, 2]

      # other types are disregarded
      assert_valid schema, 5
    end
  end

  module AdditionalItemsTests
    def test_additional_items_false
      schema = {
        'items' => [
          { 'type' => 'integer' },
          { 'type' => 'string' },
        ],
        'additionalItems' => false,
      }

      assert_valid schema, [1, 'string']
      assert_valid schema, [1]
      assert_valid schema, []
      refute_valid schema, [1, 'string', 2]
      refute_valid schema, ['string', 1]
    end

    def test_additional_items_schema
      schema = {
        'items' => [
          { 'type' => 'integer' },
          { 'type' => 'string' },
        ],
        'additionalItems' => { 'type' => 'integer' },
      }

      assert_valid schema, [1, 'string']
      assert_valid schema, [1, 'string', 2]
      refute_valid schema, [1, 'string', 'string']
    end
  end

  module UniqueItemsTests
    def test_unique_items
      schema = { 'uniqueItems' => true }

      assert_valid schema, [nil, 5]
      refute_valid schema, [nil, nil]

      assert_valid schema, [true, false]
      refute_valid schema, [true, true]

      assert_valid schema, [4, 4.1]
      refute_valid schema, [4, 4]

      assert_valid schema, %w[a ab]
      refute_valid schema, %w[a a]

      assert_valid schema, [[1], [2]]
      refute_valid schema, [[1], [1]]

      assert_valid schema, [{ 'b' => 1 }, { 'c' => 2 }]
      assert_valid schema, [{ 'b' => 1 }, { 'c' => 1 }]
      refute_valid schema, [{ 'b' => 1 }, { 'b' => 1 }]
    end
  end
end
