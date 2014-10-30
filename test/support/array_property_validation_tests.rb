module ArrayPropertyValidationTests
  def test_minitems
    schema = {
      'properties' => {
        'a' => { 'minItems' => 1 }
      }
    }

    assert_valid schema, { 'a' => [1] }
    assert_valid schema, { 'a' => [1, 2] }
    refute_valid schema, { 'a' => [] }

    # other types are disregarded
    assert_valid schema, 5
  end

  def test_maxitems
    schema = {
      'properties' => {
        'a' => { 'maxItems' => 1 }
      }
    }

    assert_valid schema, { 'a' => [] }
    assert_valid schema, { 'a' => [1] }
    refute_valid schema, { 'a' => [1, 2] }

    # other types are disregarded
    assert_valid schema, 5
  end
end
