require File.expand_path('../test_helper', __FILE__)

class RubySchemaTest < MiniTest::Unit::TestCase
  def test_string_keys
    schema = {
      "type" => 'object',
      "required" => ["a"],
      "properties" => {
        "a" => {"type" => "integer", "default" => 42},
        "b" => {"type" => "integer"}
      }
    }

    assert_valid schema, { "a" => 5 }
  end

  def test_symbol_keys
    schema = {
      :type => 'object',
      :required => ["a"],
      :properties => {
        :a => {:type => "integer", :default => 42},
        :b => {:type => "integer"}
      }
    }

    assert_valid schema, { :a => 5 }
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
