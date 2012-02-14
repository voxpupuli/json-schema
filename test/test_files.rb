require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class JSONSchemaTest < Test::Unit::TestCase
  
  #
  # These tests are ONLY run if there is an appropriate JSON backend parser available
  #
  
  def test_schema_from_file
    if JSON::Validator.json_backend != nil
      data = {"a" => 5}
      assert(JSON::Validator.validate(File.join(File.dirname(__FILE__),"schemas/good_schema_1.json"),data))
      data = {"a" => "bad"}
      assert(!JSON::Validator.validate(File.join(File.dirname(__FILE__),"schemas/good_schema_1.json"),data))
    end
  end
  
  def test_data_from_file
    if JSON::Validator.json_backend != nil
      schema = {"type" => "object", "properties" => {"a" => {"type" => "integer"}}}
      assert(JSON::Validator.validate(schema,File.join(File.dirname(__FILE__),"data/good_data_1.json")))
      assert(!JSON::Validator.validate(schema,File.join(File.dirname(__FILE__),"data/bad_data_1.json")))
    end
  end
  
  def test_both_from_file
    if JSON::Validator.json_backend != nil
      assert(JSON::Validator.validate(File.join(File.dirname(__FILE__),"schemas/good_schema_1.json"),File.join(File.dirname(__FILE__),"data/good_data_1.json")))
      assert(!JSON::Validator.validate(File.join(File.dirname(__FILE__),"schemas/good_schema_1.json"),File.join(File.dirname(__FILE__),"data/bad_data_1.json")))
    end
  end
    
  def test_file_ref
    if JSON::Validator.json_backend != nil
      data = {"b" => {"a" => 5}}
      assert(JSON::Validator.validate(File.join(File.dirname(__FILE__),"schemas/good_schema_2.json"),data))
  
      data = {"b" => {"a" => "boo"}}
      assert(!JSON::Validator.validate(File.join(File.dirname(__FILE__),"schemas/good_schema_1.json"),data))
    end
  end
end
