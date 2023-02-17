module NumberValidation
  module MinMaxTests
    def test_minimum
      schema = {
        'properties' => {
          'a' => { 'minimum' => 5 },
        },
      }

      assert_valid schema, { 'a' => 5 }
      assert_valid schema, { 'a' => 6 }

      refute_valid schema, { 'a' => 4 }
      refute_valid schema, { 'a' => 4.99999 }

      # other types are disregarded
      assert_valid schema, { 'a' => 'str' }
    end

    def test_exclusive_minimum
      schema = {
        'properties' => {
          'a' => { 'minimum' => 5 }.merge(exclusive_minimum),
        },
      }

      assert_valid schema, { 'a' => 6 }
      assert_valid schema, { 'a' => 5.0001 }
      refute_valid schema, { 'a' => 5 }
    end

    def test_maximum
      schema = {
        'properties' => {
          'a' => { 'maximum' => 5 },
        },
      }

      assert_valid schema, { 'a' => 4 }
      assert_valid schema, { 'a' => 5 }

      refute_valid schema, { 'a' => 6 }
      refute_valid schema, { 'a' => 5.0001 }
    end

    def test_exclusive_maximum
      schema = {
        'properties' => {
          'a' => { 'maximum' => 5 }.merge(exclusive_maximum),
        },
      }

      assert_valid schema, { 'a' => 4 }
      assert_valid schema, { 'a' => 4.99999 }
      refute_valid schema, { 'a' => 5 }
    end
  end

  # draft3 introduced `divisibleBy`, renamed to `multipleOf` in draft4.
  # Favor the newer name, but the behavior should be identical.
  module MultipleOfTests
    def multiple_of
      'multipleOf'
    end

    def test_multiple_of
      schema = {
        'properties' => {
          'a' => { multiple_of => 1.1 },
        },
      }

      assert_valid schema, { 'a' => 0 }

      assert_valid schema, { 'a' => 2.2 }
      refute_valid schema, { 'a' => 3.4 }

      # other types are disregarded
      assert_valid schema, { 'a' => 'hi' }
    end
  end
end
