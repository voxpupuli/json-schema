require File.expand_path('../support/test_helper', __FILE__)

class FragmentResolutionTest < Minitest::Test
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

    assert_raises JSON::Schema::Pointer::PointerSyntaxError do
      JSON::Validator.validate!(schema,data,:fragment => "/properties/a")
    end

    assert_raises JSON::Schema::Pointer::ReferenceError do
      JSON::Validator.validate!(schema,data,:fragment => "#/properties/b")
    end
  end

  def test_odd_level_fragment_resolution
    schema = {
      "foo" => {
        "type" => "object",
        "required" => ["a"],
        "properties" => {
          "a" => {"type" => "integer"}
        }
      }
    }

    assert_valid schema, {"a" => 1}, :fragment => "#/foo"
    refute_valid schema, {}, :fragment => "#/foo"
  end

  def test_even_level_fragment_resolution
    schema = {
      "foo" => {
        "bar" => {
          "type" => "object",
          "required" => ["a"],
          "properties" => {
            "a" => {"type" => "integer"}
          }
        }
      }
    }

    assert_valid schema, {"a" => 1}, :fragment => "#/foo/bar"
    refute_valid schema, {}, :fragment => "#/foo/bar"
  end

  def test_fragment_resolution_with_array
    document = {
      "definitions" => {
        "schemas" => [
          {
            "type" => "object",
            "required" => ["a"],
            "properties" => {
              "a" => {
                "type" => "object",
              }
            }
          },
          {
            "type" => "object",
            "properties" => {
              "b" => {"type" => "integer" }
            }
          }
        ]
      }
    }

    data = {"b" => 5}
    refute_valid document, data, :fragment => "#/definitions/schemas/0"
    assert_valid document, data, :fragment => "#/definitions/schemas/1"
  end

  def test_array_fragment_resolution
    schema = {
      "type" => "object",
      "required" => ["a"],
      "properties" => {
        "a" => {
          "anyOf" => [
            {"type" => "integer"},
            {"type" => "string"}
          ]
        }
      }
    }

    refute_valid schema, "foo", :fragment => "#/properties/a/anyOf/0"
    assert_valid schema, "foo", :fragment => "#/properties/a/anyOf/1"

    assert_valid schema, 5, :fragment => "#/properties/a/anyOf/0"
    refute_valid schema, 5, :fragment => "#/properties/a/anyOf/1"
  end
  def test_fragment_resolution_with_special_chars
    document = {
      "de~fi/nitions" => {
        "schemas" => [
          {
            "type" => "object",
            "required" => ["a"],
            "properties" => {
              "a" => {
                "type" => "object",
              }
            }
          },
          {
            "type" => "object",
            "properties" => {
              "b" => {"type" => "integer" }
            }
          }
        ]
      }
    }

    data = {"b" => 5}
    refute_valid document, data, :fragment => "#/de~0fi~1nitions/schemas/0"
    assert_valid document, data, :fragment => "#/de~0fi~1nitions/schemas/1"
  end
end
