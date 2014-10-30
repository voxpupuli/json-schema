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

module ArrayUniqueItemsValidationTests
  def test_unique_items
    schema = {
      'properties' => {
        'a' => { 'uniqueItems' => true }
      }
    }

    assert_valid schema, {'a' => [nil, 5]}
    refute_valid schema, {'a' => [nil, nil]}

    assert_valid schema, {'a' => [true, false]}
    refute_valid schema, {'a' => [true, true]}

    assert_valid schema, {'a' => [4, 4.1]}
    refute_valid schema, {'a' => [4, 4]}

    assert_valid schema, {'a' => ['a', 'ab']}
    refute_valid schema, {'a' => ['a', 'a']}

    assert_valid schema, {'a' => [[1], [2]]}
    refute_valid schema, {'a' => [[1], [1]]}

    assert_valid schema, {'a' => [{'b' => 1}, {'c' => 2}]}
    assert_valid schema, {'a' => [{'b' => 1}, {'c' => 1}]}
    refute_valid schema, {'a' => [{'b' => 1}, {'b' => 1}]}
  end
end
