require File.expand_path('../test_helper', __FILE__)

class RubySchemaTest < Minitest::Test
  STRING_SCHEMA = {
    "type" => 'object',
    "required" => ["a"],
    "properties" => {
      "a" => {"type" => "integer", "default" => 42},
      "b" => {"type" => "integer"}
    }
  }

  SYMBOL_SCHEMA = {
    :type => 'object',
    :required => ["a"],
    :properties => {
      :a => {:type => "integer", :default => 42},
      :b => {:type => "integer"}
    }
  }

  [[STRING_SCHEMA, 'string'], [SYMBOL_SCHEMA, 'symbol']].each do |schema, type|
    define_method("test_#{type}_schema_keys") do
      assert_valid schema, { "a" => 5 }
    end

    define_method("test_#{type}_schema_keys_ignores_symbol_data_keys") do
      refute_valid schema, { :a => 5 }
    end

    define_method("test_#{type}_schema_keys_converts_symbol_data_keys") do
      data = { :a => 5 }
      assert_valid schema, data, stringify_data_keys: true
      assert_equal({'a' => 5}, data)
    end

    define_method("test_#{type}_schema_keys_ignores_symbol_data_keys_insert_defaults") do
      data = { :a => 5 }
      assert_valid schema, data, insert_defaults: true
      assert_equal({:a => 5, 'a' => 42}, data)
    end

    define_method("test_#{type}_schema_keys_converts_symbol_data") do
      data = { :a => 5 }
      assert_valid schema, data, insert_defaults: true, stringify_data_keys: true
      assert_equal({'a' => 5}, data)
    end
  end

  def test_symbol_keys_in_hash_within_array
    schema = {
      :type => 'object',
      :properties => {
        :a => {
          :type => "array",
          :items => [
            {
              :properties => {
                :b => {
                  :type => "integer"
                }
              }
            }
          ]
        }
      }
    }

    data = {
      :a => [
        {
          :b => 1
        }
      ]
    }

    assert_valid schema, data, :validate_schema => true
  end
end
