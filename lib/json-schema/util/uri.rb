module JSON
  module Util
    module URI
      def self.normalized_uri(uri)
        uri = Addressable::URI.parse(uri) if uri.is_a?(String)
        # Check for absolute path
        if uri.relative?
          data = uri.to_s
          data = "#{Dir.pwd}/#{data}" if data[0,1] != '/'
          uri = Addressable::URI.convert_path(data)
        end
        uri
      end
    end
  end
end
