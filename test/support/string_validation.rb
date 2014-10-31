module StringValidation
  module ValueTests
    def test_minlength
      schema = {
        'properties' => {
          'a' => { 'minLength' => 1 }
        }
      }

      assert_valid schema, {'a' => 't'}
      refute_valid schema, {'a' => ''}

      # other types are disregarded
      assert_valid schema, {'a' => 5}
    end

    def test_maxlength
      schema = {
        'properties' => {
          'a' => { 'maxLength' => 2 }
        }
      }

      assert_valid schema, {'a' => 'tt'}
      assert_valid schema, {'a' => ''}
      refute_valid schema, {'a' => 'ttt'}

      # other types are disregarded
      assert_valid schema, {'a' => 5}
    end

    def test_pattern
      schema = {
        'properties' => {
          'a' => { 'pattern' => "\\d+ taco" }
        }
      }

      assert_valid schema, {'a' => '156 taco bell'}
      refute_valid schema, {'a' => 'x taco'}

      # other types are disregarded
      assert_valid schema, {'a' => 5}
    end
  end
end
