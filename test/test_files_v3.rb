require File.expand_path('../test_helper', __FILE__)

class JSONSchemaTest < Minitest::Test

  def test_schema_from_file
    assert_valid schema_fixture_path('good_schema_1.json'), { "a" => 5 }
    refute_valid schema_fixture_path('good_schema_1.json'), { "a" => "bad" }
  end

  def test_file_ref
    assert_valid schema_fixture_path('good_schema_2.json'), { "b" => { "a" => 5 } }
    refute_valid schema_fixture_path('good_schema_1.json'), { "b" => { "a" => "boo" } }
  end

  def test_file_extends
    assert_valid schema_fixture_path('good_schema_extends1.json'), { "a" => 5 }
    assert_valid schema_fixture_path('good_schema_extends2.json'), { "a" => 5, "b" => { "a" => 5 } }
  end

end
