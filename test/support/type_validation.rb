module TypeValidation
  # The draft4 schema refers to the JSON types as 'simple types';
  # see draft4#/definitions/simpleTypes
  module SimpleTypeTests
    TYPES = {
      'integer' => 5,
      'number' => 5.0,
      'string' => 'str',
      'boolean' => true,
      'object' => {},
      'array' => [],
      'null' => nil,
    }

    TYPES.each do |name, value|
      other_values = TYPES.values.reject { |v| v == value }

      define_method(:"test_#{name}_type_property") do
        schema = {
          'properties' => { 'a' => { 'type' => name } },
        }
        assert_valid schema, { 'a' => value }

        other_values.each do |other_value|
          refute_valid schema, { 'a' => other_value }
        end
      end

      define_method(:"test_#{name}_type_value") do
        schema = { 'type' => name }
        assert_valid schema, value

        other_values.each do |other_value|
          schema = { 'type' => name }
          refute_valid schema, other_value
        end
      end
    end

    def test_type_union
      schema = { 'type' => %w[integer string] }
      assert_valid schema, 5
      assert_valid schema, 'str'
      refute_valid schema, nil
      refute_valid schema, [5, 'str']
    end
  end

  # The draft1..3 schemas support an additional type, `any`.
  module AnyTypeTests
    def test_any_type
      schema = { 'type' => 'any' }

      SimpleTypeTests::TYPES.each_value do |value|
        assert_valid schema, value
      end
    end
  end

  # The draft1..3 schemas support schemas as values for `type`.
  module SchemaUnionTypeTests
    def test_union_type_with_schemas
      schema = {
        'properties' => {
          'a' => {
            'type' => [
              { 'type' => 'string' },
              { 'type' => 'object', 'properties' => { 'b' => { 'type' => 'integer' } } },
            ],
          },
        },
      }

      assert_valid schema, { 'a' => 'test' }
      refute_valid schema, { 'a' => 5 }

      assert_valid schema, { 'a' => { 'b' => 5 } }
      refute_valid schema, { 'a' => { 'b' => 'taco' } }
    end
  end
end
