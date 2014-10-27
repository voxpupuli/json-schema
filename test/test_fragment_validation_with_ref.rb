require_relative 'test_helper'

class FragmentValidationWithRef < Test::Unit::TestCase
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
    v = nil
    assert_nothing_raised do
      v = JSON::Validator.fully_validate(whole_schema,data,:fragment => "#/definitions/posts")
    end

    assert(v.empty?, v.join("\n"))
  end
end
