module JSON
  module Util
    module URI
      def self.normalized_uri(data)
        uri = Addressable::URI.parse(data)
        # Check for absolute path
        if uri.relative?
          data = data.to_s
          data = "#{Dir.pwd}/#{data}" if data[0,1] != '/'
          uri = Addressable::URI.convert_path(data)
        end
        uri
      end
    end
  end
end
