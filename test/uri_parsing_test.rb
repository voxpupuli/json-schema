# coding: utf-8

require File.expand_path('../support/test_helper', __FILE__)

class UriParsingTest < Minitest::Test
  def test_asian_characters
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'id' => 'http://俺:鍵@例え.テスト/p?条件#ここ#',
      'type' => 'object',
      'required' => ['a'],
      'properties' => {
        'a' => {
          'id' => 'a',
          'type' => 'integer',
        },
      },
    }
    data = { 'a' => 5 }
    assert_valid schema, data
  end

  def test_schema_ref_with_empty_fragment
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
      'required' => ['names'],
      'properties' => {
        'names' => {
          'type' => 'array',
          'items' => {
            'anyOf' => [
              { '$ref' => 'test/schemas/ref john with spaces schema.json#' },
            ],
          },
        },
      },
    }
    data = { 'names' => [{ 'first' => 'john' }] }
    assert_valid schema, data
  end

  def test_schema_ref_from_file_with_spaces
    schema = {
      '$schema' => 'http://json-schema.org/draft-04/schema#',
      'type' => 'object',
      'required' => ['names'],
      'properties' => {
        'names' => {
          'type' => 'array',
          'items' => {
            'anyOf' => [
              { '$ref' => 'test/schemas/ref john with spaces schema.json' },
            ],
          },
        },
      },
    }
    data = { 'names' => [{ 'first' => 'john' }] }
    assert_valid schema, data
  end

  def test_schema_from_file_with_spaces
    data = { 'first' => 'john' }
    schema = 'test/schemas/ref john with spaces schema.json'
    assert_valid schema, data
  end
end
