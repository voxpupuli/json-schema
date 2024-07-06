require 'addressable/uri'
require 'concurrent'

module JSON
  module Util
    module URI
      SUPPORTED_PROTOCOLS = %w(http https ftp tftp sftp ssh svn+ssh telnet nntp gopher wais ldap prospero)

      @cache_mutex = Mutex.new

      class << self
        def parse(uri)
          if uri.is_a?(Addressable::URI)
            uri.dup
          else
            @parse_cache ||= {}
            parsed_uri = @parse_cache[uri]
            if parsed_uri
              parsed_uri.dup
            else
              @parse_cache[uri] = Addressable::URI.parse(uri)
            end
          end
        rescue Addressable::URI::InvalidURIError => e
          raise JSON::Schema::UriError, e.message
        end

        def clear_cache
          cache_mutex.synchronize do
            @parse_cache = {}
          end
        end

        private

        # @!attribute cache_mutex
        #   @return [Mutex]
        attr_reader :cache_mutex
      end
    end
  end
end
