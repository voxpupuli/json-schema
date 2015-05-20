require 'singleton'

module JSON
  module Util
    class URI
      include Singleton
      attr_accessor :parse_cache, :normalized_cache

      def normalized_uri(uri)
        uri = self.class.parse(uri) unless uri.is_a?(Addressable::URI)
        # Check for absolute path
        if uri.relative?
          data = uri.to_s
          data = "#{Dir.pwd}/#{data}" if data[0,1] != '/'
          uri = Addressable::URI.convert_path(data)
        end
        uri
      end

      # These caches create a race condition in multithreaded environments
      # This is OK because the worst case result of the race is
      # a cache miss
      def self.parse(uri)
        instance.parse_cache ||= {}
        instance.parse_cache[uri.to_s.freeze] ||= Addressable::URI.parse(uri)
      end

      def self.normalized_uri(uri)
        instance.normalized_cache ||= {}
        instance.normalized_cache[uri.to_s.freeze] ||= instance.normalized_uri(uri)
      end
    end
  end
end
