require File.expand_path('../support/test_helper', __FILE__)

class FragmentValidationWithRefTest < Minitest::Test
  def whole_schema
    {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "definitions" => {
        "post" => {
          "type" => "object",
          "properties" => {
            "content" => {
              "type" => "string"
            },
            "author" => {
              "type" => "string"
            }
          }
        },
        "posts" => {
          "type" => "array",
          "items" => {
            "$ref" => "#/definitions/post"
          }
        }
      }
    }
  end

  def test_validation_of_fragment
    data = [{"content" => "ohai", "author" => "Bob"}]
    assert_valid whole_schema, data, :fragment => "#/definitions/posts"
  end
end
