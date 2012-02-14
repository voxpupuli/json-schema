require 'json/pure' unless defined?(::JSON)
require File.join(File.dirname(__FILE__),'../engines/json_common')

module MultiJson
  module Engines
    # Use JSON pure to encode/decode.
    class JsonPure
      ParseError = ::JSON::ParserError
      extend JsonCommon
    end
  end
end
