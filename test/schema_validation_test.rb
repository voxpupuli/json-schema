require File.expand_path('../support/test_helper', __FILE__)
require 'tmpdir'

class SchemaValidationTest < Minitest::Test
  def valid_schema_v3
    {
      '$schema' => 'http://json-schema.org/draft-03/schema#',
      'type' => 'object',
      'properties' => {
        'b' => {
          'required' => true,
        },
      },
    }
  end

  def invalid_schema_v3
    {
      '$schema' => 'http://json-schema.org/draft-03/schema#',
      'type' => 'object',
      'properties' => {
        'b' => {
          'required' => 'true',
        },
      },
    }
  end

  def valid_schema_v4
    {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
      'required' => ['b'],
      'properties' => {
      },
    }
  end

  def invalid_schema_v4
    {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
      'required' => 'b',
      'properties' => {
      },
    }
  end

  def symbolized_schema
    {
      type: :object,
      required: %i[
        id
        name
        real_name
        role
        website
        biography
        created_at
        demographic
      ],
      properties: {
        id: {
          type: [
            :integer,
          ],
        },
        name: {
          type: [
            :string,
          ],
        },
        real_name: {
          type: [
            :string,
          ],
        },
        role: {
          type: [
            :string,
          ],
        },
        website: {
          type: %i[
            string
            null
          ],
        },
        created_at: {
          type: [
            :string,
          ],
        },
        biography: {
          type: %i[
            string
            null
          ],
        },
      },
      relationships: {
        demographic: {
          type: :object,
          required: %i[
            id
            gender
          ],
          properties: {
            id: {
              type: [
                :integer,
              ],
            },
            gender: {
              type: [
                :string,
              ],
            },
          },
        },
      },
    }
  end

  def test_draft03_validation
    data = { 'b' => { 'a' => 5 } }
    assert(JSON::Validator.validate(valid_schema_v3, data, validate_schema: true, version: :draft3))
    assert(!JSON::Validator.validate(invalid_schema_v3, data, validate_schema: true, version: :draft3))
  end

  def test_validate_just_schema_draft03
    errors = JSON::Validator.fully_validate_schema(valid_schema_v3, version: :draft3)
    assert_equal [], errors

    errors = JSON::Validator.fully_validate_schema(invalid_schema_v3, version: :draft3)
    assert_equal 1, errors.size
    assert_match(/the property .*required.*did not match/i, errors.first)
  end

  def test_draft04_validation
    data = { 'b' => { 'a' => 5 } }
    assert(JSON::Validator.validate(valid_schema_v4, data, validate_schema: true, version: :draft4))
    assert(!JSON::Validator.validate(invalid_schema_v4, data, validate_schema: true, version: :draft4))
  end

  def test_validate_just_schema_draft04
    errors = JSON::Validator.fully_validate_schema(valid_schema_v4, version: :draft4)
    assert_equal [], errors

    errors = JSON::Validator.fully_validate_schema(invalid_schema_v4, version: :draft4)
    assert_equal 1, errors.size
    assert_match(/the property .*required.*did not match/i, errors.first)
  end

  def test_validate_schema_3_without_version_option
    data = { 'b' => { 'a' => 5 } }
    assert(JSON::Validator.validate(valid_schema_v3, data, validate_schema: true))
    assert(!JSON::Validator.validate(invalid_schema_v3, data, validate_schema: true))
  end

  def test_schema_validation_from_different_directory
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        data = { 'b' => { 'a' => 5 } }
        assert(JSON::Validator.validate(valid_schema_v4, data, validate_schema: true, version: :draft4))
        assert(!JSON::Validator.validate(invalid_schema_v4, data, validate_schema: true, version: :draft4))
      end
    end
  end

  def test_validate_schema_with_symbol_keys
    data = {
      'created_at' => '2014-01-25T00:58:33-08:00',
      'id' => 8517194300913402149003,
      'name' => 'chelsey',
      'real_name' => 'Mekhi Hegmann',
      'website' => nil,
      'role' => 'user',
      'biography' => nil,
      'demographic' => nil,
    }
    assert(JSON::Validator.validate!(symbolized_schema, data, validate_schema: true))
  end

  def test_validate_schema_no_additional_properties
    errors = JSON::Validator.fully_validate_schema(symbolized_schema, noAdditionalProperties: true)
    assert_equal 1, errors.size
    assert_match(/the property .* contained undefined properties: .*relationships/i, errors.first)

    schema_without_additional_properties = symbolized_schema
    schema_without_additional_properties.delete(:relationships)
    errors = JSON::Validator.fully_validate_schema(schema_without_additional_properties, noAdditionalProperties: true)
    assert_equal 0, errors.size
  end
end
