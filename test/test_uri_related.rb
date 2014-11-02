# coding: utf-8
require File.expand_path('../test_helper', __FILE__)

class UriRelatedTest < Minitest::Test
  def test_asian_characters
    schema = {
      "$schema"=> "http://json-schema.org/draft-04/schema#",
      "id"=> "http://俺:鍵@例え.テスト/p?条件#ここ#",
      "type" => "object",
      "required" => ["a"],
      "properties" => {
        "a" => {
          "id" => "a",
          "type" => "integer"
        }
      }
    }
    data = { "a" => 5 }
    assert_valid schema, data
  end
end
