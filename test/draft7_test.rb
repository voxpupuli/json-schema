# encoding: utf-8
require File.expand_path('../support/test_helper', __FILE__)

class Draft7Test < Minitest::Test
  include ArrayValidation::ItemsTests
  include ArrayValidation::AdditionalItemsTests
  include ArrayValidation::UniqueItemsTests

  include EnumValidation::General
  include EnumValidation::V3_V4

  include ObjectValidation::AdditionalPropertiesTests
  include ObjectValidation::PatternPropertiesTests

  include StrictValidation

  include StringValidation::ValueTests
  include StringValidation::FormatTests

  include TypeValidation::SimpleTypeTests

  def validation_errors(schema, data, options)
    super(schema, data, version: :draft7)
  end

  def ipv4_format
    'ipv4'
  end

  def test_definition
    schema = JSON.parse(
      %q(
        {
          "$id": "http://example.com/schema#",
          "type": "object",
          "$schema": "http://json-schema.org/draft-07/schema#",
          "definitions": {
            "schema": {
              "$id": "#/definitions/schema",
              "$ref": "http://json-schema.org/draft-07/schema#",
              "default": {}
            }
          },
          "properties": {
            "name": {
              "$id": "/properties/name",
              "type": "string",
              "title": "Name",
              "description": "Name.",
              "minLength": 1
            }
          }
        }
      )
    )

    data = {name: 'Example'}.to_json
    assert_valid schema, data

    data = {name: ''}.to_json
    refute_valid schema, data
  end
end
