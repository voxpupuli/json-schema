require File.expand_path('../support/test_helper', __FILE__)

class NoAdditionalPropertiesAllOfTest < Minitest::Test
  def schema
    {
      '$schema': 'http://json-schema.org/draft-04/schema#',
      type: 'object',
      allOf: [
        {
          type: 'object',
          properties: {
            a: {
              type: 'integer',
            },
          },
          required: ['a'],
        },
        {
          type: 'object',
          properties: {
            b: {
              type: 'string',
            },
          },
          required: ['b'],
        },
      ],
    }
  end

  def data
    {
      a: 1,
      b: 'hello',
    }
  end

  def test_all_of_ref_message
     assert_valid schema, data, { noAdditionalProperties: true }
  end

  def test_all_of_failure
    data = {
      a: 1,
      b: 'hello',
      c: 'something',
    }

    assert_raises JSON::Schema::ValidationError do
      JSON::Validator.validate!(schema, data, noAdditionalProperties: true)
    end
  end
end
