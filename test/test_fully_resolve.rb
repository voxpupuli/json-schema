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

  def test_resolution_of_draft_4_spec
    stub_request(:get, "http://json-schema.org/draft-04/schema#").to_return(:body => File.new('resources/draft-04.json'), :status => 200)
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "$ref" => "http://json-schema.org/draft-04/schema#"
    }

    schema_array = {
      "type" => "array",
      "minItems" => 1,
      "items" => { "$ref" => "#" }
    }
    positive_integer = {
      "type" => "integer",
      "minimum" => 0
    }
    positive_integer_default_0 = {
      "allOf" => [ positive_integer, { "default" => 0 } ]
    }
    string_array = {
      "type" => "array",
      "items" => { "type" => "string" },
      "minItems" => 1,
      "uniqueItems" => true
    }
    simple_types = {
      "enum" => [ "array", "boolean", "integer", "null", "number", "object", "string" ]
    }
    expected = {}
    expected.merge!({
      "id" => "http://json-schema.org/draft-04/schema#",
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "description" => "Core schema meta-schema",
      "definitions" => {
          "schemaArray" => schema_array,
          "positiveInteger" => positive_integer,
          "positiveIntegerDefault0" => positive_integer_default_0,
          "simpleTypes" => simple_types,
          "stringArray" => string_array
      },
      "type" => "object",
      "properties" => {
          "id" => {
              "type" => "string",
              "format" => "uri"
          },
          "$schema" => {
              "type" => "string",
              "format" => "uri"
          },
          "title" => {
              "type" => "string"
          },
          "description" => {
              "type" => "string"
          },
          "default" => {},
          "multipleOf" => {
              "type" => "number",
              "minimum" => 0,
              "exclusiveMinimum" => true
          },
          "maximum" => {
              "type" => "number"
          },
          "exclusiveMaximum" => {
              "type" => "boolean",
              "default" => false
          },
          "minimum" => {
              "type" => "number"
          },
          "exclusiveMinimum" => {
              "type" => "boolean",
              "default" => false
          },
          "maxLength" => positive_integer,
          "minLength" => positive_integer_default_0,
          "pattern" => {
              "type" => "string",
              "format" => "regex"
          },
          "additionalItems" => {
              "anyOf" => [
                  { "type" => "boolean" },
                  expected
              ],
              "default" => {}
          },
          "items" => {
              "anyOf" => [
                  expected,
                  schema_array
              ],
              "default" => {}
          },
          "maxItems" => positive_integer,
          "minItems" => positive_integer_default_0,
          "uniqueItems" => {
              "type" => "boolean",
              "default" => false
          },
          "maxProperties" => positive_integer,
          "minProperties" => positive_integer_default_0,
          "required" => string_array,
          "additionalProperties" => {
              "anyOf" => [
                  { "type" => "boolean" },
                  expected
              ],
              "default" => {}
          },
          "definitions" => {
              "type" => "object",
              "additionalProperties" => expected,
              "default" => {}
          },
          "properties" => {
              "type" => "object",
              "additionalProperties" => expected,
              "default" => {}
          },
          "patternProperties" => {
              "type" => "object",
              "additionalProperties" => expected,
              "default" => {}
          },
          "dependencies" => {
              "type" => "object",
              "additionalProperties" => {
                  "anyOf" => [
                      expected,
                      string_array
                  ]
              }
          },
          "enum" => {
              "type" => "array",
              "minItems" => 1,
              "uniqueItems" => true
          },
          "type" => {
              "anyOf" => [
                  simple_types,
                  {
                      "type" => "array",
                      "items" => simple_types,
                      "minItems" => 1,
                      "uniqueItems" => true
                  }
              ]
          },
          "allOf" => schema_array,
          "anyOf" => schema_array,
          "oneOf" => schema_array,
          "not" => expected
      },
      "dependencies" => {
          "exclusiveMaximum" => [ "maximum" ],
          "exclusiveMinimum" => [ "minimum" ]
      },
      "default" => {}
    })
    schema_array['items'] = expected

    resolved = JSON::Validator.fully_resolve(schema)
    assert_equal(resolved, expected, "should resolve the draft 4 spec")

    assert_valid(schema, schema)
  end
end


