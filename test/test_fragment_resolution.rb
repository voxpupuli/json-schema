require File.expand_path('../test_helper', __FILE__)

class FragmentResolution < Test::Unit::TestCase
  def test_fragment_resolution
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "required" => ["a"],
      "properties" => {
        "a" => {
          "type" => "object",
          "properties" => {
            "b" => {"type" => "integer" }
          }
        }
      }
    }

    data = {"b" => 5}
    refute_valid schema, data
    assert_valid schema, data, :fragment => "#/properties/a"

    assert_raise JSON::Schema::SchemaError do
      JSON::Validator.validate!(schema,data,:fragment => "/properties/a")
    end

    assert_raise JSON::Schema::SchemaError do
      JSON::Validator.validate!(schema,data,:fragment => "#/properties/b")
    end
  end
end
