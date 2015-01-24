# encoding: utf-8
require File.expand_path('../test_helper', __FILE__)

class FullyResovleDraft4Test < Minitest::Test
  def test_top_level_ref
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "$ref" => "test/schemas/fully_resolve/leave_string_schema.json#"
    }

    expected = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "required" => ["name"],
      "properties"  => {
        "name"  => { "type" => "string" }
      }
    }

    resolved = JSON::Validator.fully_resolve(schema)
    assert_equal(resolved, expected, "should resolve a top level $ref reference")

    # Test that the result is usable for validation
    data = {name: '2'}
    assert_valid(schema, data)
    assert_valid(resolved, data)
  end

  def test_one_of_ref
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "oneOf" => [
        { "$ref" => "test/schemas/fully_resolve/leave_string_schema.json#" },
        { "$ref" => "test/schemas/fully_resolve/leave_integer_schema.json#" }
      ]
    }

    expected = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "oneOf" => [
        {
          "$schema" => "http://json-schema.org/draft-04/schema#",
          "type" => "object",
          "required" => ["name"],
          "properties"  => {
            "name"  => { "type" => "string" }
          }
        },
        {
          "$schema" => "http://json-schema.org/draft-04/schema#",
          "type" => "object",
          "required" => ["age"],
          "properties"  => {
            "age"  => { "type" => "integer" }
          }
        }
      ]
    }

    resolved = JSON::Validator.fully_resolve(schema)
    assert_equal(resolved, expected, "should resolve a top level $ref reference")

    # Test that the result is usable for validation
    data = {name: '2'}
    assert_valid(schema, data)
    assert_valid(resolved, data)

    data = {age: 2}
    assert_valid(schema, data)
    assert_valid(resolved, data)
  end

  def test_linked_list_ref
    stub_request(:get, "example.com/linked_list").to_return(:body => File.new('test/schemas/fully_resolve/linked_list_schema.json'), :status => 200)

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "$ref" => "http://example.com/linked_list#"
      # it does not work to reference the schema by path
      # "$ref" => 'test/schemas/fully_resolve/linked_list_schema.json'
    }

    expected = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "id" => "http://example.com/linked_list#",
      "type" => "object",
      "required" => ["head", "tail"],
      "properties"  => {
        "head"  => {
          "type" => "object"
        },
        "tail" => {
        }
      }
    }
    expected["properties"]["tail"]["oneOf"] = [
      expected,
      { "type" => "null" }
    ]

    resolved = JSON::Validator.fully_resolve(schema)
    assert_equal(resolved, expected, "should resolve a top level $ref reference")

    data = {"head" => {}, "tail" => nil}
    assert_valid(schema, data)
    # you don't want to do that it causes infinite recursion aka SystemStackError: stack level too deep
    #assert_valid(resolved, data)
  end
end


