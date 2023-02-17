module ObjectValidation
  module AdditionalPropertiesTests
    def test_additional_properties_false
      schema = {
        'properties' => {
          'a' => { 'type' => 'integer' },
        },
        'additionalProperties' => false,
      }

      assert_valid schema, { 'a' => 1 }
      refute_valid schema, { 'a' => 1, 'b' => 2 }
    end

    def test_additional_properties_schema
      schema = {
        'properties' => {
          'a' => { 'type' => 'integer' },
        },
        'additionalProperties' => { 'type' => 'string' },
      }

      assert_valid schema, { 'a' => 1 }
      assert_valid schema, { 'a' => 1, 'b' => 'hi' }
      refute_valid schema, { 'a' => 1, 'b' => 2 }
    end
  end

  module PatternPropertiesTests
    def test_pattern_properties
      schema = {
        'patternProperties' => {
          '\\d+ taco' => { 'type' => 'integer' },
        },
      }

      assert_valid schema, { '1 taco' => 1, '20 taco' => 20 }
      assert_valid schema, { 'foo' => true, '1 taco' => 1 }
      refute_valid schema, { '1 taco' => 'yum' }
    end

    def test_pattern_properties_additional_properties_false
      schema = {
        'patternProperties' => {
          '\\d+ taco' => { 'type' => 'integer' },
        },
        'additionalProperties' => false,
      }

      assert_valid schema, { '1 taco' => 1 }
      refute_valid schema, { '1 taco' => 'yum' }
      refute_valid schema, { '1 taco' => 1, 'foo' => true }
    end

    def test_pattern_properties_additional_properties_schema
      schema = {
        'patternProperties' => {
          '\\d+ taco' => { 'type' => 'integer' },
        },
        'additionalProperties' => { 'type' => 'string' },
      }

      assert_valid schema, { '1 taco' => 1 }
      assert_valid schema, { '1 taco' => 1, 'foo' => 'bar' }
      refute_valid schema, { '1 taco' => 1, 'foo' => 2 }
    end
  end
end
