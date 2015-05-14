require 'singleton'

module JSON
  module Util
    class URI
      include Singleton
      attr_accessor :cache

      def normalized_uri(uri)
        uri = Addressable::URI.parse(uri) unless uri.is_a?(Addressable::URI)
        # Check for absolute path
        if uri.relative?
          data = uri.to_s
          data = "#{Dir.pwd}/#{data}" if data[0,1] != '/'
          uri = Addressable::URI.convert_path(data)
        end
        uri
      end

      def self.normalized_uri(uri)
        instance.cache ||= {}
        instance.cache[uri] ||= instance.normalized_uri(uri)
      end
    end
  end
end
