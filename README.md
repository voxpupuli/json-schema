![https://travis-ci.org/ruby-json-schema/json-schema](https://travis-ci.org/ruby-json-schema/json-schema.svg?branch=master)
![https://codeclimate.com/github/ruby-json-schema/json-schema](https://codeclimate.com/github/ruby-json-schema/json-schema/badges/gpa.svg)

Ruby JSON Schema Validator
==========================

This library is intended to provide Ruby with an interface for validating JSON
objects against a JSON schema conforming to [JSON Schema Draft
4](http://tools.ietf.org/html/draft-zyp-json-schema-04). Legacy support for
[JSON Schema Draft 3](http://tools.ietf.org/html/draft-zyp-json-schema-03),
[JSON Schema Draft 2](http://tools.ietf.org/html/draft-zyp-json-schema-02), and
[JSON Schema Draft 1](http://tools.ietf.org/html/draft-zyp-json-schema-01) is
also included.

Additional Resources
--------------------

- [Google Groups](https://groups.google.com/forum/#!forum/ruby-json-schema)
- #ruby-json-schema on chat.freenode.net

Version 2.0.0 Upgrade Notes
---------------------------

Please be aware that the upgrade to version 2.0.0 will use Draft-04 **by
default**, so schemas that do not declare a validator using the `$schema`
keyword will use Draft-04 now instead of Draft-03. This is the reason for the
major version upgrade.

Installation
------------

From rubygems.org:

```sh
gem install json-schema
```

From the git repo:

```sh
$ gem build json-schema.gemspec
$ gem install json-schema-2.5.2.gem
```

Usage
-----

Three base validation methods exist: 

1. `validate`: returns a boolean on whether a validation attempt passes
2. `validate!`: throws a `JSON::Schema::ValidationError` with an appropriate message/trace on where the validation failed
3. `fully_validate`: builds an array of validation errors return when validation is complete

All methods take two arguments, which can be either a JSON string, a file
containing JSON, or a Ruby object representing JSON data. The first argument to
these methods is always the schema, the second is always the data to validate.
An optional third options argument is also accepted; available options are used
in the examples below.

By default, the validator uses the [JSON Schema Draft
4](http://tools.ietf.org/html/draft-zyp-json-schema-04) specification for
validation; however, the user is free to specify additional specifications or
extend existing ones. Legacy support for Draft 1, Draft 2, and Draft 3 is
included by either passing an optional `:version` parameter to the `validate`
method (set either as `:draft1` or `draft2`), or by declaring the `$schema`
attribute in the schema and referencing the appropriate specification URI. Note
that the `$schema` attribute takes precedence over the `:version` option during
parsing and validation.

### Validate Ruby objects against a Ruby schema

For further information on json schema itself refer to <a
href="http://spacetelescope.github.io/understanding-json-schema/">Understanding
JSON Schema</a>.

```rb
require 'rubygems'
require 'json-schema'

schema = {
  "type" => "object",
  "required" => ["a"],
  "properties" => {
    "a" => {"type" => "integer"}
  }
}

data = {
  "a" => 5
}

JSON::Validator.validate(schema, data)
```

### Validate a JSON string against a JSON schema file

```rb
require 'rubygems'
require 'json-schema'

JSON::Validator.validate('schema.json', '{"a" : 5}')
```

### Validate a list of objects against a schema that represents the individual objects

```rb
require 'rubygems'
require 'json-schema'

data = ['user','user','user']
JSON::Validator.validate('user.json', data, :list => true)
```

### Strictly validate an object's properties

With the `:strict` option, validation fails when an object contains properties
that are not defined in the schema's property list or doesn't match the
`additionalProperties` property. Furthermore, all properties are treated as
`required` regardless of `required` properties set in the schema.

```rb
require 'rubygems'
require 'json-schema'

schema = {
  "type" => "object",
  "properties" => {
    "a" => {"type" => "integer"},
    "b" => {"type" => "integer"}
  }
}

JSON::Validator.validate(schema, {"a" => 1, "b" => 2}, :strict => true)            # ==> true
JSON::Validator.validate(schema, {"a" => 1, "b" => 2, "c" => 3}, :strict => true)  # ==> false
JSON::Validator.validate(schema, {"a" => 1}, :strict => true)                      # ==> false
```

### Catch a validation error and print it out

```rb
require 'rubygems'
require 'json-schema'

schema = {
  "type" => "object",
  "required" => ["a"],
  "properties" => {
    "a" => {"type" => "integer"}
  }
}

data = {
  "a" => "taco"
}

begin
  JSON::Validator.validate!(schema, data)
rescue JSON::Schema::ValidationError
  puts $!.message
end
```

### Fully validate against a schema and catch all errors

```rb
require 'rubygems'
require 'json-schema'

schema = {
  "type" => "object",
  "required" => ["a","b"],
  "properties" => {
    "a" => {"type" => "integer"},
    "b" => {"type" => "string"}
  }
}

data = {
  "a" => "taco"
}

errors = JSON::Validator.fully_validate(schema, data)

# ["The property '#/a' of type String did not match the following type: integer in schema 03179a21-197e-5414-9611-e9f63e8324cd#", "The property '#/' did not contain a required property of 'b' in schema 03179a21-197e-5414-9611-e9f63e8324cd#"]
```

### Fully validate against a schema and catch all errors as objects

```rb
require 'rubygems'
require 'json-schema'

schema = {
  "type" => "object",
  "required" => ["a","b"],
  "properties" => {
    "a" => {"type" => "integer"},
    "b" => {"type" => "string"}
  }
}

data = {
  "a" => "taco"
}

errors = JSON::Validator.fully_validate(schema, data, :errors_as_objects => true)

# [{:message=>"The property '#/a' of type String did not match the following type: integer in schema 03179a21-197e-5414-9611-e9f63e8324cd#", :schema=>#, :failed_attribute=>"Type", :fragment=>"#/a"}, {:message=>"The property '#/' did not contain a required property of 'b' in schema 03179a21-197e-5414-9611-e9f63e8324cd#", :schema=>#, :failed_attribute=>"Properties", :fragment=>"#/"}]
```

### Validate against a fragment of a supplied schema

```rb
require 'rubygems'
require 'json-schema'

schema = {
  "type" => "object",
  "required" => ["a","b"],
  "properties" => {
    "a" => {"type" => "integer"},
    "b" => {"type" => "string"},
    "c" => {
      "type" => "object",
      "properties" => {
        "z" => {"type" => "integer"}
      }
    }
  }
}

data = {
  "z" => 1
}

JSON::Validator.validate(schema, data, :fragment => "#/properties/c")
```

### Validate a JSON object against a JSON schema object, while also validating the schema itself

```rb
require 'rubygems'
require 'json-schema'

schema = {
  "type" => "object",
  "required" => ["a"],
  "properties" => {
    "a" => {"type" => "integer", "required" => "true"}  # This will fail schema validation!
  }
}

data = {
  "a" => 5
}

JSON::Validator.validate(schema, data, :validate_schema => true)
```

### Validate a JSON object against a JSON schema object, while inserting default values from the schema

With the `:insert_defaults` option set to true any missing property that has a
default value specified in the schema will be inserted into the validated data.
The inserted default value is validated hence catching a schema that specifies
an invalid default value.

```rb
require 'rubygems'
require 'json-schema'

schema = {
  "type" => "object",
  "required" => ["a"],
  "properties" => {
    "a" => {"type" => "integer", "default" => 42},
    "b" => {"type" => "integer"}
  }
}

# Would not normally validate because "a" is missing and required by schema,
# but "default" option allows insertion of valid default.
data = {
  "b" => 5
}

JSON::Validator.validate(schema, data)
# false

JSON::Validator.validate(schema, data, :insert_defaults => true)
# true
# data = {
#   "a" => 42,
#   "b" => 5
# }
```

### Validate an object against a JSON Schema Draft 2 schema

```rb
require 'rubygems'
require 'json-schema'

schema = {
  "type" => "object",
  "properties" => {
    "a" => {"type" => "integer", "optional" => true}
  }
}

data = {
  "a" => 5
}

JSON::Validator.validate(schema, data, :version => :draft2)
```

### Explicitly specifying the type of the data

By default, json-schema accepts a variety of different types for the data
parameter, and it will try to work out what to do with it dynamically. You can
pass it a string uri (in which case it will download the json from that location
before validating), a string of JSON text, or simply a ruby object (such as an
array or hash representing parsed json). However, sometimes the nature of the
data is ambiguous (for example, is "http://github.com" just a string, or is it a
uri?). In other situations, you have already parsed your JSON, and you don't
need to re-parse it.

If you want to be explict about what kind of data is being parsed, JSON schema
supports a number of options:

```rb
require 'rubygems'
require 'json-schema'

schema = {
  "type" => "string"
}

# examines the data, determines it's a uri, then tries to load data from it
JSON::Validator.validate(schema, 'https://api.github.com') # returns false

# data is already parsed json - just accept it as-is
JSON::Validator.validate(schema, 'https://api.github.com', :parse_data => false) # returns true

# data is parsed to a json string
JSON::Validator.validate(schema, '"https://api.github.com"', :json => true) # returns true

# loads data from the uri
JSON::Validator.validate(schema, 'https://api.github.com', :uri => true) # returns false
```

### Extend an existing schema and validate against it

For this example, we are going to extend the [JSON Schema Draft
3](http://tools.ietf.org/html/draft-zyp-json-schema-03) specification by adding
a 'bitwise-and' property for validation.

```rb
require 'rubygems'
require 'json-schema'

class BitwiseAndAttribute < JSON::Schema::Attribute
  def self.validate(current_schema, data, fragments, processor, validator, options = {})
    if data.is_a?(Integer) && data & current_schema.schema['bitwise-and'].to_i == 0
      message = "The property '#{build_fragment(fragments)}' did not evaluate  to true when bitwise-AND'd with  #{current_schema.schema['bitwise-or']}"
      raise JSON::Schema::ValidationError.new(message, fragments, current_schema)
    end
  end
end

class ExtendedSchema < JSON::Schema::Validator
  def initialize
    super
    extend_schema_definition("http://json-schema.org/draft-03/schema#")
    @attributes["bitwise-and"] = BitwiseAndAttribute
    @uri = URI.parse("http://test.com/test.json")
  end

  JSON::Validator.register_validator(self.new)
end

schema = {
  "$schema" => "http://test.com/test.json",
  "properties" => {
    "a" => {
      "bitwise-and" => 1
    },
    "b" => {
      "type" => "string"
    }
  }
}

data = {
  "a" => 0
}

data = {"a" => 1, "b" => "taco"}
JSON::Validator.validate(schema,data) # => true
data = {"a" => 1, "b" => 5}
JSON::Validator.validate(schema,data) # => false
data = {"a" => 0, "b" => "taco"}
JSON::Validator.validate(schema,data) # => false
```

### Custom format validation

The JSON schema standard allows custom formats in schema definitions which
should be ignored by validators that do not support them. JSON::Schema allows
registering procs as custom format validators which receive the value to be
checked as parameter and must raise a `JSON::Schema::CustomFormatError` to
indicate a format violation. The error message will be prepended by the property
name, e.g. [The property '#a']()

```rb
require 'rubygems'
require 'json-schema'

format_proc = -> value {
  raise JSON::Schema::CustomFormatError.new("must be 42") unless value == "42"
}

# register the proc for format 'the-answer' for draft4 schema
JSON::Validator.register_format_validator("the-answer", format_proc, ["draft4"])

# omitting the version parameter uses ["draft1", "draft2", "draft3", "draft4"] as default
JSON::Validator.register_format_validator("the-answer", format_proc)

# deregistering the custom validator
# (also ["draft1", "draft2", "draft3", "draft4"] as default version)
JSON::Validator.deregister_format_validator('the-answer', ["draft4"])

# shortcut to restore the default formats for validators (same default as before)
JSON::Validator.restore_default_formats(["draft4"])

# with the validator registered as above, the following results in
# ["The property '#a' must be 42"] as returned errors
schema = {
  "$schema" => "http://json-schema.org/draft-04/schema#",
  "properties" => {
    "a" => {
      "type" => "string",
      "format" => "the-answer",
    }
  }
}
errors = JSON::Validator.fully_validate(schema, {"a" => "23"})
```

Controlling Remote Schema Reading
---------------------------------

In some cases, you may wish to prevent the JSON Schema library from making HTTP
calls or reading local files in order to resolve `$ref` schemas. If you fully
control all schemas which should be used by validation, this could be
accomplished by registering all referenced schemas with the validator in
advance:

```rb
schema = JSON::Schema.new(some_schema_definition, Addressable::URI.parse('http://example.com/my-schema'))
JSON::Validator.add_schema(schema)
```

If more extensive control is necessary, the `JSON::Schema::Reader` instance used
can be configured in a few ways:

```rb
# Change the default schema reader used
JSON::Validator.schema_reader = JSON::Schema::Reader.new(:accept_uri => true, :accept_file => false)

# For this validation call, use a reader which only accepts URIs from my-website.com
schema_reader = JSON::Schema::Reader.new(
  :accept_uri => proc { |uri| uri.host == 'my-website.com' }
)
JSON::Validator.validate(some_schema, some_object, :schema_reader => schema_reader)
```

The `JSON::Schema::Reader` interface requires only an object which responds to
`read(string)` and returns a `JSON::Schema` instance. See the [API
documentation](http://www.rubydoc.info/github/ruby-json-schema/json-schema/master/JSON/Schema/Reader)
for more information.

JSON Backends
-------------

The JSON Schema library currently supports the `json` and `yajl-ruby` backend
JSON parsers. If either of these libraries are installed, they will be
automatically loaded and used to parse any JSON strings supplied by the user.

If more than one of the supported JSON backends are installed, the `yajl-ruby`
parser is used by default. This can be changed by issuing the following before
validation:

```rb
JSON::Validator.json_backend = :json
```

Optionally, the JSON Schema library supports using the MultiJSON library for
selecting JSON backends. If the MultiJSON library is installed, it will be
autoloaded.

Notes
-----

The 'format' attribute is only validated for the following values:

- date-time
- date
- time
- ip-address (IPv4 address in draft1, draft2 and draft3)
- ipv4 (IPv4 address in draft4)
- ipv6
- uri

All other 'format' attribute values are simply checked to ensure the instance
value is of the correct datatype (e.g., an instance value is validated to be an
integer or a float in the case of 'utc-millisec').

Additionally, JSON::Validator does not handle any json hyperschema attributes.
