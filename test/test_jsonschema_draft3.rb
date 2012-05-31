require 'test/unit'
require File.dirname(__FILE__) + '/../lib/json-schema'

class JSONSchemaDraft3Test < Test::Unit::TestCase
  def test_types
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
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
    
    assert(JSON::Validator.validate({'type' => 'integer'}, 3))
    assert(!JSON::Validator.validate({'type' => 'integer'}, "hello"))
    
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
    
    assert(JSON::Validator.validate({'type' => 'number'}, 3))
    assert(JSON::Validator.validate({'type' => 'number'}, 3.14159265358979))
    assert(!JSON::Validator.validate({'type' => 'number'}, "hello"))
    
    
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
    
    assert(JSON::Validator.validate({'type' => 'string'}, 'hello'))
    assert(!JSON::Validator.validate({'type' => 'string'}, 3.14159265358979))
    assert(!JSON::Validator.validate({'type' => 'string'}, []))
    
    
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
    
    assert(JSON::Validator.validate({'type' => 'boolean'}, true))
    assert(JSON::Validator.validate({'type' => 'boolean'}, false))
    assert(!JSON::Validator.validate({'type' => 'boolean'}, nil))
    assert(!JSON::Validator.validate({'type' => 'boolean'}, 3))
    assert(!JSON::Validator.validate({'type' => 'boolean'}, "hello"))
    
    
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
    
    assert(JSON::Validator.validate({'type' => 'object'}, {'a' => true}))
    assert(JSON::Validator.validate({'type' => 'object'}, {}))
    assert(!JSON::Validator.validate({'type' => 'object'}, []))
    assert(!JSON::Validator.validate({'type' => 'object'}, 3))
    assert(!JSON::Validator.validate({'type' => 'object'}, "hello"))
    
    
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
    
    assert(JSON::Validator.validate({'type' => 'array'}, ['a']))
    assert(JSON::Validator.validate({'type' => 'array'}, []))
    assert(!JSON::Validator.validate({'type' => 'array'}, {}))
    assert(!JSON::Validator.validate({'type' => 'array'}, 3))
    assert(!JSON::Validator.validate({'type' => 'array'}, "hello"))
    
    
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
    
    assert(JSON::Validator.validate({'type' => 'null'}, nil))
    assert(!JSON::Validator.validate({'type' => 'null'}, false))
    assert(!JSON::Validator.validate({'type' => 'null'}, []))
    assert(!JSON::Validator.validate({'type' => 'null'}, "hello"))
    
    
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
    
    assert(JSON::Validator.validate({'type' => 'any'}, true))
    assert(JSON::Validator.validate({'type' => 'any'}, nil))
    assert(JSON::Validator.validate({'type' => 'any'}, {}))
    assert(JSON::Validator.validate({'type' => 'any'}, 3))
    assert(JSON::Validator.validate({'type' => 'any'}, "hello"))
    
    
    # Test a union type
    schema["properties"]["a"]["type"] = ["integer","string"]
    data["a"] = 5
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = 'boo'
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = false
    assert(!JSON::Validator.validate(schema,data))
    
    assert(JSON::Validator.validate({'type' => ['string', 'null']}, "hello"))
    assert(!JSON::Validator.validate({'type' => ['integer', 'object']}, "hello"))
    
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {"required" => true}
      }
    }
    data = {}
    
    assert(!JSON::Validator.validate(schema,data))
    data['a'] = "Hello"
    assert(JSON::Validator.validate(schema,data))
    
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {"type" => "integer"}
      }
    }
    
    data = {}
    assert(JSON::Validator.validate(schema,data))
    
  end
  
  
  
  def test_minimum
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
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
    
    # Test a non-string
    data["a"] = 5
    assert(JSON::Validator.validate(schema,data))
    
    data["a"] = "taco"
    assert(!JSON::Validator.validate(schema,data))
  end
  
  
  def test_min_length
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
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
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => { "type" => "integer"}
      } 
    }
    
    schema2 = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
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
  
  def test_pattern_properties
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "patternProperties" => {
        "\\d+ taco" => {"type" => "integer"}
      }
    }
    
    data = {
      "a" => true,
      "1 taco" => 1,
      "20 tacos" => 20
    }
    
    assert(JSON::Validator.validate(schema,data))
    data["20 tacos"] = "string!"
    assert(!JSON::Validator.validate(schema,data))
  end
  
  
  def test_additional_properties
    # Test no additional properties allowed
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => { "type" => "integer" }
      },
      "additionalProperties" => false
    }
    
    data = {
      "a" => 10
    }
    
    assert(JSON::Validator.validate(schema,data))
    data["b"] = 5
    assert(!JSON::Validator.validate(schema,data))
    
    # Test additional properties match a schema
    schema["additionalProperties"] = { "type" => "string" }
    data["b"] = "taco"
    assert(JSON::Validator.validate(schema,data))
    data["b"] = 5
    assert(!JSON::Validator.validate(schema,data))
    
    # Make sure this works with pattern properties set, too
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "patternProperties" => {
        "\\d+ taco" => {"type" => "integer"}
      },
      "additionalProperties" => false
    }
    
    data = {
      "5 tacos" => 5,
      "20 tacos" => 20
    }
    
    assert(JSON::Validator.validate(schema,data))
    data["b"] = 5
    assert(!JSON::Validator.validate(schema,data))
  end
  
  
  def test_items
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "items" => { "type" => "integer" }
    }
    
    data = [1,2,4]
    assert(JSON::Validator.validate(schema,data))
    data = [1,2,"string"]
    assert(!JSON::Validator.validate(schema,data))
    
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "items" => [
        {"type" => "integer"},
        {"type" => "string"}
      ]
    }
    
    data = [1,"string"]
    assert(JSON::Validator.validate(schema,data))
    data = [1,"string",3]
    assert(JSON::Validator.validate(schema,data))
    data = ["string",1]
    assert(!JSON::Validator.validate(schema,data))
    
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "items" => [
        {"type" => "integer"},
        {"type" => "string"}
      ],
      "additionalItems" => false
    }
    
    data = [1,"string"]
    assert(JSON::Validator.validate(schema,data))
    data = [1,"string",3]
    assert(!JSON::Validator.validate(schema,data))
    
    schema = {"$schema" => "http://json-schema.org/draft-03/schema#","items" => [{"type" => "integer"},{"type" => "string"}],"additionalItems" => {"type" => "integer"}}
    
    data = [1,"string"]
    assert(JSON::Validator.validate(schema,data))
    data = [1,"string",3]
    assert(JSON::Validator.validate(schema,data))
    data = [1,"string","string"]
    assert(!JSON::Validator.validate(schema,data))
  end
  
  
  def test_list_option
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "integer", "required" => true} }
    }
    
    data = [{"a" => 1},{"a" => 2},{"a" => 3}]
    assert(JSON::Validator.validate(schema,data,:list => true))
    assert(!JSON::Validator.validate(schema,data))    
    
    data = {"a" => 1}
    assert(!JSON::Validator.validate(schema,data,:list => true))
    
    data = [{"a" => 1},{"b" => 2},{"a" => 3}]
    assert(!JSON::Validator.validate(schema,data,:list => true))
  end
  
  
  def test_self_reference
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "integer"}, "b" => {"$ref" => "#"}}
    }
    
    data = {"a" => 5, "b" => {"b" => {"a" => 1}}}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => 5, "b" => {"b" => {"a" => 'taco'}}}
    assert(!JSON::Validator.validate(schema,data))
  end
  
  
  def test_format_ipv4
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "ip-address"}}
    }
    
    data = {"a" => "1.1.1.1"}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => "1.1.1"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "1.1.1.300"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => 5}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "1.1.1"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "1.1.1.1b"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "b1.1.1.1"}
  end
  
  
  def test_format_ipv6
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "ipv6"}}
    }
    
    data = {"a" => "1111:2222:8888:9999:aaaa:cccc:eeee:ffff"}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => "1111:0:8888:0:0:0:eeee:ffff"}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => "1111:2222:8888::eeee:ffff"}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => "1111:2222:8888:99999:aaaa:cccc:eeee:ffff"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "1111:2222:8888:9999:aaaa:cccc:eeee:gggg"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "1111:2222::9999::cccc:eeee:ffff"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "1111:2222:8888:9999:aaaa:cccc:eeee:ffff:bbbb"}
    assert(!JSON::Validator.validate(schema,data))
  end
  
  def test_format_time
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "time"}}
    }
    
    data = {"a" => "12:00:00"}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => "12:00"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "12:00:60"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "12:60:00"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "24:00:00"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "0:00:00"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "-12:00:00"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "12:00:00b"}
    assert(!JSON::Validator.validate(schema,data))
  end
  
  
  def test_format_date
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "date"}}
    }
    
    data = {"a" => "2010-01-01"}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-32"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "n2010-01-01"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "2010-1-01"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-1"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-01n"}
    assert(!JSON::Validator.validate(schema,data))
  end
  
  def test_format_datetime
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "date-time"}}
    }
    
    data = {"a" => "2010-01-01T12:00:00Z"}
    assert(JSON::Validator.validate(schema,data))
  data = {"a" => "2010-01-01T12:00:00.1Z"}
    assert(JSON::Validator.validate(schema,data))
	data = {"a" => "2010-01-01T12:00:00,1Z"}
    assert(JSON::Validator.validate(schema,data))	
    data = {"a" => "2010-01-32T12:00:00Z"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "2010-13-01T12:00:00Z"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-01T24:00:00Z"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-01T12:60:00Z"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-01T12:00:60Z"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-01T12:00:00"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-01T12:00:00z"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-0112:00:00Z"}
    assert(!JSON::Validator.validate(schema,data))
  end
  
  
  def test_format_union
    data1 = {"a" => "boo"}
    data2 = {"a" => nil}
    
    schema = {
      "type" => "object",
      "properties" => { "a" => {"type" => ["string","null"], "format" => "ip-address"}}
    }
    assert(!JSON::Validator.validate(schema,data1,:version => :draft3))
    assert(JSON::Validator.validate(schema,data2,:version => :draft3))
  end
  
  
  
  def test_schema
    schema = {
      "$schema" => "http://json-schema.org/THIS-IS-NOT-A-SCHEMA",
      "type" => "object"
    }
    
    data = {"a" => "taco"}
    assert(!JSON::Validator.validate(schema,data))
    
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "type" => "object"
    }
    assert(JSON::Validator.validate(schema,data))
  end
  
  def test_dependency
    schema = {
      "type" => "object",
      "properties" => {
        "a" => {"type" => "integer"},
        "b" => {"type" => "integer"}
      },
      "dependencies" => {
        "a" => "b"
      }
    }
    
    data = {"a" => 1, "b" => 2}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => 1}
    assert(!JSON::Validator.validate(schema,data))
    
    schema = {
      "type" => "object",
      "properties" => {
        "a" => {"type" => "integer"},
        "b" => {"type" => "integer"},
        "c" => {"type" => "integer"}
      },
      "dependencies" => {
        "a" => ["b","c"]
      }
    }
    
    data = {"a" => 1, "c" => 2}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => 1, "b" => 2, "c" => 3}
    assert(JSON::Validator.validate(schema,data))
  end
  
  
end

