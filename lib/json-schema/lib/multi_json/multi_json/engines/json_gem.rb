require 'json' unless defined?(::JSON)
require File.join(File.dirname(__FILE__),'../engines/json_common')

module MultiJson
  module Engines
    # Use the JSON gem to encode/decode.
    class JsonGem
      ParseError = ::JSON::ParserError
      extend JsonCommon
    end
  end
end
