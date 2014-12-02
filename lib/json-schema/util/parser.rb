module JSON
  module Util
    module Parser
      def self.parse(string)
        begin
          JSON.parse(string, :quirks_mode => true)
        rescue JSON::ParserError => e
          raise JSON::Schema::JsonParseError.new(e.message)
        end
      end

      def self.serialize(hash)
        JSON.dump(hash)
      end
    end
  end
end
