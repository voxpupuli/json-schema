# encoding: utf-8
require_relative 'test_helper'

class JSONSchemaDraft4Test < Test::Unit::TestCase
  def test_types
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
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

    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'integer'}, 3))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'integer'}, "hello"))

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

    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'number'}, 3))
    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'number'}, 3.14159265358979))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'number'}, "hello"))


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

    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'string'}, 'hello'))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'string'}, 3.14159265358979))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'string'}, []))


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

    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'boolean'}, true))
    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'boolean'}, false))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'boolean'}, nil))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'boolean'}, 3))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'boolean'}, "hello"))

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

    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'object'}, {'a' => true}))
    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'object'}, {}))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'object'}, []))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'object'}, 3))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'object'}, "hello"))


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

    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'array'}, ['a']))
    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'array'}, []))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'array'}, {}))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'array'}, 3))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'array'}, "hello"))


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

    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'null'}, nil))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'null'}, false))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'null'}, []))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'null'}, "hello"))


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

    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'any'}, true))
    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'any'}, nil))
    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'any'}, {}))
    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'any'}, 3))
    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => 'any'}, "hello"))


    # Test a union type
    schema["properties"]["a"]["type"] = ["integer","string"]
    data["a"] = 5
    assert(JSON::Validator.validate(schema,data))

    data["a"] = 'boo'
    assert(JSON::Validator.validate(schema,data))

    data["a"] = false
    assert(!JSON::Validator.validate(schema,data))

    assert(JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => ['string', 'null']}, "hello"))
    assert(!JSON::Validator.validate({"$schema" => "http://json-schema.org/draft-04/schema#",'type' => ['integer', 'object']}, "hello"))
  end

  def test_required
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "required" => ["a"],
      "properties" => {
        "a" => {}
      }
    }
    data = {}

    assert(!JSON::Validator.validate(schema,data))
    data['a'] = "Hello"
    assert(JSON::Validator.validate(schema,data))

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
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


  def test_min_properties
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "minProperties" => 2,
      "properties" => {
      }
    }

    data = {"a" => nil}
    assert(!JSON::Validator.validate(schema,data))

    data = {"a" => nil, "b" => nil}
    assert(JSON::Validator.validate(schema,data))

    data = {"a" => nil, "b" => nil, "c" => nil}
    assert(JSON::Validator.validate(schema,data))
  end



  def test_max_properties
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "maxProperties" => 2,
      "properties" => {
      }
    }

    data = {"a" => nil}
    assert(JSON::Validator.validate(schema,data))

    data = {"a" => nil, "b" => nil}
    assert(JSON::Validator.validate(schema,data))

    data = {"a" => nil, "b" => nil, "c" => nil}
    assert(!JSON::Validator.validate(schema,data))
  end

    def test_strict_properties
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"type" => "string"},
        "b" => {"type" => "string"}
      }
    }

    data = {"a" => "a"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"b" => "b"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b"}
    assert(JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b", "c" => "c"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))
  end

  def test_strict_properties_additional_props
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"type" => "string"},
        "b" => {"type" => "string"}
      },
      "additionalProperties" => {"type" => "integer"}
    }

    data = {"a" => "a"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"b" => "b"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b"}
    assert(JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b", "c" => "c"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b", "c" => 3}
    assert(JSON::Validator.validate(schema,data,:strict => true))
  end

  def test_strict_properties_pattern_props
    schema = {
      "$schema" => "http://json-schema.org/draft-03/schema#",
      "properties" => {
        "a" => {"type" => "string"},
        "b" => {"type" => "string"}
      },
      "patternProperties" => {"\\d+ taco" => {"type" => "integer"}}
    }

    data = {"a" => "a"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"b" => "b"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b"}
    assert(JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b", "c" => "c"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b", "c" => 3}
    assert(!JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b", "23 taco" => 3}
    assert(JSON::Validator.validate(schema,data,:strict => true))

    data = {"a" => "a", "b" => "b", "23 taco" => "cheese"}
    assert(!JSON::Validator.validate(schema,data,:strict => true))
  end

  def test_unique_items
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
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

  def test_enum_with_schema_validation
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"enum" => [1,'boo',[1,2,3],{"a" => "b"}]}
      }
    }

    data = {
      "a" => nil
    }

    # Make sure all of the above are valid...
    data["a"] = 1
    assert(JSON::Validator.validate(schema,data,:validate_schema => true))
  end


  def test_multiple_of
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"multipleOf" => 1.1}
      }
    }

    data = {
      "a" => nil
    }

    data["a"] = 3.3
    assert(JSON::Validator.validate(schema,data))

    data["a"] = 3.4
    assert(!JSON::Validator.validate(schema,data))

    schema["properties"]["a"]["multipleOf"] = 2.0

    data["a"] = 4.0
    assert(JSON::Validator.validate(schema,data))

    data["a"] = 'boo'
    assert(JSON::Validator.validate(schema,data))

    data["a"] = 5
    schema["properties"]["a"]["multipleOf"] = 0
    assert(!JSON::Validator.validate(schema,data))
  end


  def test_pattern_properties
    # Set up the default datatype
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "items" => { "type" => "integer" }
    }

    data = [1,2,4]
    assert(JSON::Validator.validate(schema,data))
    data = [1,2,"string"]
    assert(!JSON::Validator.validate(schema,data))

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
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

    schema = {"$schema" => "http://json-schema.org/draft-04/schema#","items" => [{"type" => "integer"},{"type" => "string"}],"additionalItems" => {"type" => "integer"}}

    data = [1,"string"]
    assert(JSON::Validator.validate(schema,data))
    data = [1,"string",3]
    assert(JSON::Validator.validate(schema,data))
    data = [1,"string","string"]
    assert(!JSON::Validator.validate(schema,data))
  end


  def test_list_option
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "required" => ["a"],
      "properties" => { "a" => {"type" => "integer"} }
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "ipv4"}}
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
      "$schema" => "http://json-schema.org/draft-04/schema#",
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
    assert(JSON::Validator.validate(schema, {"a" => "::1"}), 'validate with shortcut')
    assert(!JSON::Validator.validate(schema, {"a" => "42"}), 'not validate a simple number')
  end


  def test_format_datetime
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "date-time"}}
    }

    data = {"a" => "2010-01-01T12:00:00Z"}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-01T12:00:00.1Z"}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-01T12:00:00,1Z"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-01T12:00:00+0000"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-01T12:00:00+00:00"}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-32T12:00:00Z"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "2010-13-01T12:00:00Z"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-01T24:00:00Z"}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-01T12:60:00Z"}
    assert(!JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-01T12:00:60Z"}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-01T12:00:00z"}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => "2010-01-0112:00:00Z"}
    assert(!JSON::Validator.validate(schema,data))
  end

  def test_format_uri
    data1 = {"a" => "http://gitbuh.com"}
    data2 = {"a" => "::boo"}
    data3 = {"a" => "http://ja.wikipedia.org/wiki/メインページ"}

    schema = {
        "$schema" => "http://json-schema.org/draft-04/schema#",
        "type" => "object",
        "properties" => { "a" => {"type" => "string", "format" => "uri"}}
    }

    assert(JSON::Validator.validate(schema,data1))
    assert(!JSON::Validator.validate(schema,data2))
    assert(JSON::Validator.validate(schema,data3))
  end

  def test_format_unknown
    schema = {
      "type" => "object",
      "properties" => { "a" => {"type" => "string", "format" => "unknown"}}
    }

    data = {"a" => "I can write what I want here"}
    assert(JSON::Validator.validate(schema,data,:version => :draft4))
    data = {"a" => ""}
    assert(JSON::Validator.validate(schema,data,:version => :draft4))
  end


  def test_format_union
    data1 = {"a" => "boo"}
    data2 = {"a" => nil}

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => { "a" => {"type" => ["string","null"], "format" => "ipv4"}}
    }
    assert(!JSON::Validator.validate(schema,data1))
    assert(JSON::Validator.validate(schema,data2))
  end



  def test_schema
    schema = {
      "$schema" => "http://json-schema.org/THIS-IS-NOT-A-SCHEMA",
      "type" => "object"
    }

    data = {"a" => "taco"}
    assert(!JSON::Validator.validate(schema,data))

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object"
    }
    assert(JSON::Validator.validate(schema,data))
  end

  def test_dependency
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => {
        "a" => {"type" => "integer"},
        "b" => {"type" => "integer"}
      },
      "dependencies" => {
        "a" => ["b"]
      }
    }

    data = {"a" => 1, "b" => 2}
    assert(JSON::Validator.validate(schema,data))
    data = {"a" => 1}
    assert(!JSON::Validator.validate(schema,data))

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
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

  def test_schema_dependency
    schema = {
      "type"=> "object",
      "properties"=> {
        "name"=> { "type"=> "string" },
        "credit_card"=> { "type"=> "number" }
      },
      "required"=> ["name"],
      "dependencies"=> {
        "credit_card"=> {
          "properties"=> {
            "billing_address"=> { "type"=> "string" }
          },
          "required"=> ["billing_address"]
        }
      }
    }
    data = {
      "name" => "John Doe",
      "credit_card" => 5555555555555555
    }
    assert(!JSON::Validator.validate(schema,data), 'test schema dependency with invalid data')
    data['billing_address'] = "Somewhere over the rainbow"
    assert(JSON::Validator.validate(schema,data), 'test schema dependency with valid data')
  end

  def test_default
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => {
        "a" => {"type" => "integer", "default" => 42},
        "b" => {"type" => "integer"}
      }
    }

    data = {"b" => 2}
    assert(JSON::Validator.validate(schema,data))
    assert_nil(data["a"])
    assert(JSON::Validator.validate(schema,data, :insert_defaults => true))
    assert_equal(42, data["a"])

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "required" => ["a"],
      "properties" => {
        "a" => {"type" => "integer", "default" => 42},
        "b" => {"type" => "integer"}
      }
    }

    data = {"b" => 2}
    assert(!JSON::Validator.validate(schema,data))
    assert_nil(data["a"])
    assert(JSON::Validator.validate(schema,data, :insert_defaults => true))
    assert_equal(42, data["a"])

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "required" => ["a"],
      "properties" => {
        "a" => {"type" => "integer", "default" => 42},
        "b" => {"type" => "integer"}
      }
    }


    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "required" => ["a"],
      "properties" => {
        "a" => {"type" => "integer", "default" => 42, "readonly" => true},
        "b" => {"type" => "integer"}
      }
    }

    data = {"b" => 2}
    assert(!JSON::Validator.validate(schema,data))
    assert_nil(data["a"])
    assert(!JSON::Validator.validate(schema,data, :insert_defaults => true))
    assert_nil(data["a"])

    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object",
      "properties" => {
        "a" => {"type" => "integer", "default" => "42"},
        "b" => {"type" => "integer"}
      }
    }

    data = {"b" => 2}
    assert(JSON::Validator.validate(schema,data))
    assert_nil(data["a"])
    assert(!JSON::Validator.validate(schema,data, :insert_defaults => true))
    assert_equal("42",data["a"])

  end


  def test_all_of
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "allOf" => [
        {
          "properties" => {"a" => {"type" => "string"}},
          "required" => ["a"]
        },
        {
          "properties" => {"b" => {"type" => "integer"}}
        }
      ]
    }

    data = {"a" => "hello", "b" => 5}
    assert(JSON::Validator.validate(schema,data))

    data = {"a" => "hello"}
    assert(JSON::Validator.validate(schema,data))

    data = {"a" => "hello", "b" => "taco"}
    assert(!JSON::Validator.validate(schema,data))

    data = {"b" => 5}
    assert(!JSON::Validator.validate(schema,data))
  end


  def test_any_of
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "anyOf" => [
        {
          "properties" => {"a" => {"type" => "string"}},
          "required" => ["a"]
        },
        {
          "properties" => {"b" => {"type" => "integer"}}
        }
      ]
    }

    data = {"a" => "hello", "b" => 5}
    assert(JSON::Validator.validate(schema,data))

    data = {"a" => "hello"}
    assert(JSON::Validator.validate(schema,data))

    data = {"a" => "hello", "b" => "taco"}
    assert(JSON::Validator.validate(schema,data))

    data = {"b" => 5}
    assert(JSON::Validator.validate(schema,data))

    data = {"a" => 5, "b" => "taco"}
    assert(!JSON::Validator.validate(schema,data))
  end


  def test_one_of
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "oneOf" => [
        {
          "properties" => {"a" => {"type" => "string"}},
          "required" => ["a"]
        },
        {
          "properties" => {"b" => {"type" => "integer"}}
        }
      ]
    }

    data = {"a" => "hello", "b" => 5}
    assert(!JSON::Validator.validate(schema,data))

    # This passes because b is not required, thus matches both schemas
    data = {"a" => "hello"}
    assert(!JSON::Validator.validate(schema,data))

    data = {"a" => "hello", "b" => "taco"}
    assert(JSON::Validator.validate(schema,data))

    data = {"b" => 5}
    assert(JSON::Validator.validate(schema,data))

    data = {"a" => 5, "b" => "taco"}
    assert(!JSON::Validator.validate(schema,data))
  end


  def test_not
    # Start with a simple not
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"not" => { "type" => ["string", "boolean"]}}
      }
    }

    data = {"a" => 1}
    assert(JSON::Validator.validate(schema,data))

    data = {"a" => "hi!"}
    assert(!JSON::Validator.validate(schema,data))

    data = {"a" => true}
    assert(!JSON::Validator.validate(schema,data))

    # Sub-schema not
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"not" => {"anyOf" => [
            {
              "type" => ["string","boolean"]
            },
            {
              "type" => "object",
              "properties" => {
                "b" => {"type" => "boolean"}
              }
            }
          ]}
        }
      }
    }

    data = {"a" => 1}
    assert(JSON::Validator.validate(schema,data))

    data = {"a" => "hi!"}
    assert(!JSON::Validator.validate(schema,data))

    data = {"a" => true}
    assert(!JSON::Validator.validate(schema,data))

    data = {"a" => {"b" => true}}
    assert(!JSON::Validator.validate(schema,data))

    data = {"a" => {"b" => 5}}
    assert(JSON::Validator.validate(schema,data))
  end

  def test_not_fully_validate
    # Start with a simple not
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "properties" => {
        "a" => {"not" => { "type" => ["string", "boolean"]}}
      }
    }

    data = {"a" => 1}
    errors = JSON::Validator.fully_validate(schema,data)
    puts errors
    assert_equal(0, errors.length)

    data = {"a" => "taco"}
    errors = JSON::Validator.fully_validate(schema,data)
    assert_equal(1, errors.length)
  end

  def test_definitions
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "array",
      "items" => { "$ref" => "#/definitions/positiveInteger"},
      "definitions" => {
        "positiveInteger" => {
          "type" => "integer",
          "minimum" => 0,
          "exclusiveMinimum" => true
        }
      }
    }

    data = [1,2,3]
    assert(JSON::Validator.validate(schema,data))

    data = [-1,2,3]
    assert(!JSON::Validator.validate(schema,data))
  end
end


