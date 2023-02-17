module EnumValidation
  module V1_V2
    def test_enum_optional
      schema = {
        'properties' => {
          'a' => { 'enum' => [1, 'boo', [1, 2, 3], { 'a' => 'b' }], 'optional' => true },
        },
      }

      data = {}
      assert_valid schema, data
    end
  end

  module V3_V4
    def test_enum_optional
      schema = {
        'properties' => {
          'a' => { 'enum' => [1, 'boo', [1, 2, 3], { 'a' => 'b' }] },
        },
      }

      data = {}
      assert_valid schema, data
    end
  end

  module General
    def test_enum_general
      schema = {
        'properties' => {
          'a' => { 'enum' => [1, 'boo', [1, 2, 3], { 'a' => 'b' }] },
        },
      }

      data = { 'a' => 1 }
      assert_valid schema, data

      data['a'] = 'boo'
      assert_valid schema, data

      data['a'] = [1, 2, 3]
      assert_valid schema, data

      data['a'] = { 'a' => 'b' }
      assert_valid schema, data

      data['a'] = 'taco'
      refute_valid schema, data
    end

    def test_enum_number_integer_includes_float
      schema = {
        'properties' => {
          'a' => {
            'type' => 'number',
            'enum' => [0, 1, 2],
          },
        },
      }

      data = { 'a' => 0 }
      assert_valid schema, data

      data['a'] = 0.0
      assert_valid schema, data

      data['a'] = 1
      assert_valid schema, data

      data['a'] = 1.0
      assert_valid schema, data
    end

    def test_enum_number_float_includes_integer
      schema = {
        'properties' => {
          'a' => {
            'type' => 'number',
            'enum' => [0.0, 1.0, 2.0],
          },
        },
      }

      data = { 'a' => 0.0 }
      assert_valid schema, data

      data['a'] = 0
      assert_valid schema, data

      data['a'] = 1.0
      assert_valid schema, data

      data['a'] = 1
      assert_valid schema, data
    end

    def test_enum_integer_excludes_float
      schema = {
        'properties' => {
          'a' => {
            'type' => 'integer',
            'enum' => [0, 1, 2],
          },
        },
      }

      data = { 'a' => 0 }
      assert_valid schema, data

      data['a'] = 0.0
      refute_valid schema, data

      data['a'] = 1
      assert_valid schema, data

      data['a'] = 1.0
      refute_valid schema, data
    end

    def test_enum_with_schema_validation
      schema = {
        'properties' => {
          'a' => { 'enum' => [1, 'boo', [1, 2, 3], { 'a' => 'b' }] },
        },
      }
      data = { 'a' => 1 }
      assert_valid(schema, data, validate_schema: true)
    end
  end
end
