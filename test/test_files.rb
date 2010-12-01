require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class JSONSchemaTest < Test::Unit::TestCase
  def test_schema_from_file
    data = {"a" => 5}
    assert(JSON::Validator.validate(File.join(File.dirname(__FILE__),"schemas/good_schema_1.json"),data))
    data = {"a" => "bad"}
    assert(!JSON::Validator.validate(File.join(File.dirname(__FILE__),"schemas/good_schema_1.json"),data))
  end
  
  def test_data_from_file
    schema = {"type" => "object", "properties" => {"a" => {"type" => "integer"}}}
    assert(JSON::Validator.validate(schema,File.join(File.dirname(__FILE__),"data/good_data_1.json")))
    assert(!JSON::Validator.validate(schema,File.join(File.dirname(__FILE__),"data/bad_data_1.json")))
  end
  
  def test_both_from_file
    assert(JSON::Validator.validate(File.join(File.dirname(__FILE__),"schemas/good_schema_1.json"),File.join(File.dirname(__FILE__),"data/good_data_1.json")))
    assert(!JSON::Validator.validate(File.join(File.dirname(__FILE__),"schemas/good_schema_1.json"),File.join(File.dirname(__FILE__),"data/bad_data_1.json")))
  end
  
  def test_invalid_schema
    data = {}
    assert_raise JSON::ParserError do
      assert(JSON::Validator.validate(File.join(File.dirname(__FILE__),"schemas/invalid_schema_1.json"),data))
    end
  end
  
  def test_invalid_data
    schema = {}
    assert_raise JSON::ParserError do
      assert(JSON::Validator.validate(schema,File.join(File.dirname(__FILE__),"data/invalid_data_1.json")))
    end
  end
  
  def test_file_ref
    data = {"b" => {"a" => 5}}
    assert(JSON::Validator.validate(File.join(File.dirname(__FILE__),"schemas/good_schema_2.json"),data))
    
    data = {"b" => {"a" => "boo"}}
    assert(!JSON::Validator.validate(File.join(File.dirname(__FILE__),"schemas/good_schema_1.json"),data))
  end
end