require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class JSONSchemaTest < Test::Unit::TestCase
  def test_types
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {}
      }
    }
    data = {
      "a" => nil
    }
    
    # Test integers
    schema["properties"]["a"]["type"] = "integer"
    data["a"] = 5
    assert(JSON::Validator.validate(schema,data))

    data["a"] = 5.2
    assert(!JSON::Validator.validate(schema,data))
    
    data['a'] = 'string'
    assert(!JSON::Validator.validate(schema,data))
    
    data['a'] = true
    assert(!JSON::Validator.validate(schema,data))
    
    
    # Test numbers
    schema["properties"]["a"]["type"] = "number"
    data["a"] = 5
    assert(JSON::Validator.validate(schema,data))

    data["a"] = 5.2
    assert(JSON::Validator.validate(schema,data))
    
    data['a'] = 'string'
    assert(!JSON::Validator.validate(schema,data))
    
    data['a'] = true
    assert(!JSON::Validator.validate(schema,data))
    
    
    # Test strings
    schema["properties"]["a"]["type"] = "string"
    data["a"] = 5
    assert(!JSON::Validator.validate(schema,data))

    data["a"] = 5.2
    assert(!JSON::Validator.validate(schema,data))
    
    data['a'] = 'string'
    assert(JSON::Validator.validate(schema,data))
    
    data['a'] = true
    assert(!JSON::Validator.validate(schema,data))
    
    
    # Test booleans
    schema["properties"]["a"]["type"] = "boolean"
    data["a"] = 5
    assert(!JSON::Validator.validate(schema,data))

    data["a"] = 5.2
    assert(!JSON::Validator.validate(schema,data))
    
    data['a'] = 'string'
    assert(!JSON::Validator.validate(schema,data))
    
    data['a'] = true
    assert(JSON::Validator.validate(schema,data))
    
    data['a'] = false
    assert(JSON::Validator.validate(schema,data))
    
    
    # Test object
    schema["properties"]["a"]["type"] = "object"
    data["a"] = {}
    assert(JSON::Validator.validate(schema,data))

    data["a"] = 5.2
    assert(!JSON::Validator.validate(schema,data))
    
    data['a'] = 'string'
    assert(!JSON::Validator.validate(schema,data))
    
    data['a'] = true
    assert(!JSON::Validator.validate(schema,data))
    
    
    # Test array
    schema["properties"]["a"]["type"] = "array"
    data["a"] = []
    assert(JSON::Validator.validate(schema,data))

    data["a"] = 5.2
    assert(!JSON::Validator.validate(schema,data))
    
    data['a'] = 'string'
    assert(!JSON::Validator.validate(schema,data))
    
    data['a'] = true
    assert(!JSON::Validator.validate(schema,data))
    
    
    # Test null
    schema["properties"]["a"]["type"] = "null"
    data["a"] = nil
    assert(JSON::Validator.validate(schema,data))

    data["a"] = 5.2
    assert(!JSON::Validator.validate(schema,data))
    
    data['a'] = 'string'
    assert(!JSON::Validator.validate(schema,data))
    
    data['a'] = true
    assert(!JSON::Validator.validate(schema,data))
    
    
    # Test any
    schema["properties"]["a"]["type"] = "any"
    data["a"] = 5
    assert(JSON::Validator.validate(schema,data))

    data["a"] = 5.2
    assert(JSON::Validator.validate(schema,data))
    
    data['a'] = 'string'
    assert(JSON::Validator.validate(schema,data))
    
    data['a'] = true
    assert(JSON::Validator.validate(schema,data))
    
    
    # Test a union type
    schema["properties"]["a"]["type"] = ["integer","string"]
    data["a"] = 5
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 'boo'
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = false
    assert(!JSON::Validator.validate(schema,data))
    
    # Test a union type with schemas
    schema["properties"]["a"]["type"] = [{ "type" => "string" }, {"type" => "object", "properties" => {"b" => {"type" => "integer"}}}]
  
    data["a"] = "test"
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 5
    assert(!JSON::Validator.validate(schema,data))
    
    data["a"] = {"b" => 5}
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = {"b" => "taco"}
    assert(!JSON::Validator.validate(schema,data))
   end
  
  
  
  def test_required
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"required" => true}
      }
    }
    data = {
    }
    
    assert(!JSON::Validator.validate(schema,data))
    data['a'] = "Hello"
    assert(JSON::Validator.validate(schema,data))
  end
  
  
  
  def test_minimum
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"minimum" => 5}
      }
    }
    
    data = {
      "a" => nil
    }
    
    
    # Test an integer
    data["a"] = 5
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 4
    assert(!JSON::Validator.validate(schema,data))
    
    # Test a float
    data["a"] = 5.0
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 4.9
    assert(!JSON::Validator.validate(schema,data))
    
    # Test a non-number
    data["a"] = "a string"
    assert(JSON::Validator.validate(schema,data))
    
    # Test exclusiveMinimum
    schema["properties"]["a"]["exclusiveMinimum"] = true
    
    data["a"] = 6
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 5
    assert(!JSON::Validator.validate(schema,data))
    
    # Test with float
    data["a"] = 5.00000001
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 5.0
    assert(!JSON::Validator.validate(schema,data))
  end
  
  
  
  def test_maximum
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"maximum" => 5}
      }
    }
    
    data = {
      "a" => nil
    }
    
    
    # Test an integer
    data["a"] = 5
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 6
    assert(!JSON::Validator.validate(schema,data))
    
    # Test a float
    data["a"] = 5.0
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 5.1
    assert(!JSON::Validator.validate(schema,data))
    
    # Test a non-number
    data["a"] = "a string"
    assert(JSON::Validator.validate(schema,data))
    
    # Test exclusiveMinimum
    schema["properties"]["a"]["exclusiveMaximum"] = true
    
    data["a"] = 4
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 5
    assert(!JSON::Validator.validate(schema,data))
    
    # Test with float
    data["a"] = 4.9999999
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 5.0
    assert(!JSON::Validator.validate(schema,data))
  end
  
  
  def test_min_items
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"minItems" => 1}
      }
    }
    
    data = {
      "a" => nil
    }
    
    # Test with an array
    data["a"] = ["boo"]
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = []
    assert(!JSON::Validator.validate(schema,data))
    
    # Test with a non-array
    data["a"] = "boo"
    assert(JSON::Validator.validate(schema,data))
  end
  
  
  
  def test_max_items
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"maxItems" => 1}
      }
    }
    
    data = {
      "a" => nil
    }
    
    # Test with an array
    data["a"] = ["boo"]
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = ["boo","taco"]
    assert(!JSON::Validator.validate(schema,data))
    
    # Test with a non-array
    data["a"] = "boo"
    assert(JSON::Validator.validate(schema,data))
  end
  
  
  
  def test_unique_items
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"uniqueItems" => true}
      }
    }
    
    data = {
      "a" => nil
    }
    
    # Test with nulls
    data["a"] = [nil,5]
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = [nil,nil]
    assert(!JSON::Validator.validate(schema,data))
    
    # Test with booleans
    data["a"] = [true,4]
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = [true,false]
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = [true,true]
    assert(!JSON::Validator.validate(schema,data))
    
    # Test with numbers
    data["a"] = [4,true]
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = [4,4.1]
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = [4,4]
    assert(!JSON::Validator.validate(schema,data))
    
    # Test with strings
    data["a"] = ['a',true]
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = ['a','ab']
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = ['a','a']
    assert(!JSON::Validator.validate(schema,data))
    
    # Test with arrays
    data["a"] = [[1],true]
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = [[1,2],[1,3]]
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = [[1,2,3],[1,2,3]]
    assert(!JSON::Validator.validate(schema,data))
    
    # Test with objects
    data["a"] = [{"a" => 1},true]
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = [{"a" => 1},{"a" => 2}]
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = [{"a" => 1, "b" => 2}, {"a" => 1, "b" => 2}]
    assert(!JSON::Validator.validate(schema,data))
  end
  
  
  def test_pattern
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"pattern" => "\\d+ taco"}
      }
    }
    
    data = {
      "a" => nil
    }
    
    # Test strings
    data["a"] = "156 taco bell"
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = "taco"
    assert(!JSON::Validator.validate(schema,data))
    
    # Test a non-string
    data["a"] = 5
    assert(JSON::Validator.validate(schema,data))
  end
  
  
  def test_min_length
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"minLength" => 1}
      }
    }
    
    data = {
      "a" => nil
    }
    
    # Try out strings
    data["a"] = "t"
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = ""
    assert(!JSON::Validator.validate(schema,data))
    
    # Try out non-string
    data["a"] = 5
    assert(JSON::Validator.validate(schema,data))
  end
  
  
  def test_max_length
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"maxLength" => 1}
      }
    }
    
    data = {
      "a" => nil
    }
    
    # Try out strings
    data["a"] = "t"
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = "tt"
    assert(!JSON::Validator.validate(schema,data))
    
    # Try out non-string
    data["a"] = 5
    assert(JSON::Validator.validate(schema,data))
  end
  
  
  def test_enum
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"enum" => [1,'boo',[1,2,3],{"a" => "b"}]}
      }
    }
    
    data = {
      "a" => nil
    }
    
    # Make sure all of the above are valid...
    data["a"] = 1
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 'boo'
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = [1,2,3]
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = {"a" => "b"}
    assert(JSON::Validator.validate(schema,data))
    
    # Test something that doesn't exist
    data["a"] = 'taco'
    assert(!JSON::Validator.validate(schema,data))
    
    # Try it without the key
    data = {}
    assert(JSON::Validator.validate(schema,data))
  end
  
  
  def test_divisible_by
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"divisibleBy" => 1.1}
      }
    }
    
    data = {
      "a" => nil
    }
    
    data["a"] = 3.3
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 3.4
    assert(!JSON::Validator.validate(schema,data))
    
    schema["properties"]["a"]["divisibleBy"] = 2.0
    
    data["a"] = 4.0
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 'boo'
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 5
    schema["properties"]["a"]["divisibleBy"] = 0
    assert(!JSON::Validator.validate(schema,data))
  end
  
  
  
  def test_disallow
    # Set up the default datatype
    schema = {
      "properties" => {
        "a" => {"disallow" => "integer"}
      }
    }
    
    data = {
      "a" => nil
    }
    
    
    data["a"] = 'string'
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 5
    assert(!JSON::Validator.validate(schema,data))
    
    
    schema["properties"]["a"]["disallow"] = ["integer","string"]
    data["a"] = 'string'
    assert(!JSON::Validator.validate(schema,data))
    
    data["a"] = 5
    assert(!JSON::Validator.validate(schema,data))
    
    data["a"] = false
    assert(JSON::Validator.validate(schema,data))

  end
  
  
  
  def test_extends
    schema = {
      "properties" => {
        "a" => { "type" => "integer"}
      } 
    }
    
    schema2 = {
      "properties" => {
        "a" => { "maximum" => 5 }
      }
    }
    
    data = {
      "a" => 10
    }
    
    assert(JSON::Validator.validate(schema,data))
    assert(!JSON::Validator.validate(schema2,data))
    
    schema["extends"] = schema2
    
    assert(!JSON::Validator.validate(schema,data))
  end
  
  
end

