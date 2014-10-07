# encoding: utf-8
require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class JSONSchemaCustomFormatTest < Test::Unit::TestCase
  def test_basic
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {
          "type" => "string",
          "format" => "custom",
        },
      }
    }
    data = {
      "a" => "42"
    }

    format_proc = -> (value) { raise JSON::Schema::CustomFormatError.new "Value must be 42" unless value == "42" }
    JSON::Validator.register_format_validator("custom", format_proc, ['draft4'])

    assert(JSON::Validator.validate(schema,data))

    data["a"] = "23"
    assert(!JSON::Validator.validate(schema,data))
  end
end


