module CommonTypeValidationTests
  # Override assert/refute valid to always specify the draft version
  def assert_valid(schema, data, options = {})
    super(schema, data, options.merge(:version => schema_version))
  end

  def refute_valid(schema, data, options = {})
    super(schema, data, options.merge(:version => schema_version))
  end

  TYPES = {
    'integer' => 5,
    'number'  => 5.0,
    'string'  => 'str',
    'boolean' => true,
    'object'  => {},
    'array'   => [],
    'null'    => nil
  }

  TYPES.each do |name, value|
    other_values = TYPES.values.reject { |v| v == value }

    define_method(:"test_#{name}_type_property") do
      schema = {
        'properties' => { 'a' => { 'type' => name } }
      }
      assert_valid schema, {'a' => value}

      other_values.each do |other_value|
        refute_valid schema, {'a' => other_value}
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
    schema = { 'type' => ['integer', 'string'] }
    assert_valid schema, 5
    assert_valid schema, 'str'
    refute_valid schema, nil
    refute_valid schema, [5, 'str']
  end
end

module AnyTypeValidationTests
  def test_any_type
    schema = { 'type' => 'any' }

    CommonTypeValidationTests::TYPES.values.each do |value|
      assert_valid schema, value
    end
  end
end

module SchemaUnionTypeValidationTests
  def test_union_type_with_schemas
    schema = {
      'properties' => {
        'a' => {
          'type' => [
            {'type' => 'string'},
            {'type' => 'object', 'properties' => { 'b' => { 'type' => 'integer' }}}
          ]
        }
      }
    }

    assert_valid schema, {'a' => 'test'}
    refute_valid schema, {'a' => 5}

    assert_valid schema, {'a' => {'b' => 5}}
    refute_valid schema, {'a' => {'b' => 'taco'}}
  end
end
