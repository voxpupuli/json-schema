module StrictValidation
  def test_strict_properties
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'properties' => {
        'a' => { 'type' => 'string' },
        'b' => { 'type' => 'string' },
      },
    }

    data = { 'a' => 'a' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'b' => 'b' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b' }
    assert(JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b', 'c' => 'c' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(!JSON::Validator.validate(schema, data, noAdditionalProperties: true))
  end

  def test_strict_error_message
    schema = { type: 'object', properties: { a: { type: 'string' } } }
    data = { a: 'abc', b: 'abc' }
    errors = JSON::Validator.fully_validate(schema, data, strict: true)
    assert_match("The property '#/' contained undefined properties: 'b' in schema", errors[0])
  end

  def test_strict_properties_additional_props
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'properties' => {
        'a' => { 'type' => 'string' },
        'b' => { 'type' => 'string' },
      },
      'additionalProperties' => { 'type' => 'integer' },
    }

    data = { 'a' => 'a' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'b' => 'b' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b' }
    assert(JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b', 'c' => 'c' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(!JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b', 'c' => 3 }
    assert(JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))
  end

  def test_strict_properties_pattern_props
    schema = {
      'properties' => {
        'a' => { 'type' => 'string' },
        'b' => { 'type' => 'string' },
      },
      'patternProperties' => { '\\d+ taco' => { 'type' => 'integer' } },
    }

    data = { 'a' => 'a' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'b' => 'b' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b' }
    assert(JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b', 'c' => 'c' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(!JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b', 'c' => 3 }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(!JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b', '23 taco' => 3 }
    assert(JSON::Validator.validate(schema, data, strict: true))
    assert(JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(JSON::Validator.validate(schema, data, noAdditionalProperties: true))

    data = { 'a' => 'a', 'b' => 'b', '23 taco' => 'cheese' }
    assert(!JSON::Validator.validate(schema, data, strict: true))
    assert(!JSON::Validator.validate(schema, data, allPropertiesRequired: true))
    assert(!JSON::Validator.validate(schema, data, noAdditionalProperties: true))
  end
end
