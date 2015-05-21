require 'singleton'

module JSON
  module Util
    class URI
      include Singleton
      attr_accessor :normalize_cache, :parse_cache

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

      # This cache creates a race condition in multithreaded environments
      # This is OK because the worst case result of the race is
      # a cache miss
      def self.normalized_uri(uri)
        instance.normalize_cache ||= {}
        instance.normalize_cache[uri] ||= instance.normalized_uri(uri)
      end

      def self.parse(uri)
        instance.parse_cache ||= {}
        instance.parse_cache[uri.to_s] ||= Addressable::URI.parse(uri)
      end
    end
  end
end
