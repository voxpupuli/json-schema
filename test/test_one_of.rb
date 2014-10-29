require_relative 'test_helper'

class OneOfTest < Test::Unit::TestCase
  def test_one_of_links_schema
    schema = File.join(File.dirname(__FILE__),"schemas/one_of_ref_links_schema.json")
    data = File.join(File.dirname(__FILE__),"data/one_of_ref_links_data.json")
    errors = JSON::Validator.fully_validate(schema,data, :errors_as_objects => true)
    assert(errors.empty?, errors.map{|e| e[:message] }.join("\n"))
  end


  def test_one_of_with_string_patterns
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "oneOf" => [
        {
          "properties" => {"a" => {"type" => "string", "pattern" => "foo"}},
        },
        {
          "properties" => {"a" => {"type" => "string", "pattern" => "bar"}},
        },
        {
          "properties" => {"a" => {"type" => "string", "pattern" => "baz"}},
        }
      ]
    }

    data = {"a" => "foo"}
    assert(JSON::Validator.validate(schema,data))

    data = {"a" => "foobar"}
    assert(!JSON::Validator.validate(schema,data))

    data = {"a" => "baz"}
    assert(JSON::Validator.validate(schema,data))

    data = {"a" => 5}
    assert(!JSON::Validator.validate(schema,data))
  end

end
