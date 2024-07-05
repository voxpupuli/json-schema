require 'addressable/uri'
require 'concurrent'

module JSON
  module Util
    module URI
      SUPPORTED_PROTOCOLS = %w(http https ftp tftp sftp ssh svn+ssh telnet nntp gopher wais ldap prospero)

      @cache_mutex = Mutex.new
      @unescaped_path_cache = Concurrent::Map.new
      @file_uri_cache = Concurrent::Map.new

      class << self
        def normalized_uri(uri, base_path = Dir.pwd)
          @normalize_cache ||= {}
          normalized_uri = @normalize_cache[uri]

          if !normalized_uri
            normalized_uri = parse(uri)
            # Check for absolute path
            if normalized_uri.relative?
              data = normalized_uri
              data = File.join(base_path, data) if data.path[0, 1] != '/'
              normalized_uri = file_uri(data)
            end
            @normalize_cache[uri] = normalized_uri.freeze
          end

          normalized_uri
        end

        def absolutize_ref(ref, base)
          ref_uri = strip_fragment(ref.dup)

          return ref_uri if ref_uri.absolute?
          return parse(base) if ref_uri.path.empty?

          uri = strip_fragment(base.dup).join(ref_uri.path)
          normalized_uri(uri)
        end

        def normalize_ref(ref, base)
          ref_uri = parse(ref)
          base_uri = parse(base)

          ref_uri.defer_validation do
            if ref_uri.relative?
              ref_uri.merge!(base_uri)

              # Check for absolute path
              path, fragment = ref.to_s.split('#')
              if path.nil? || path == ''
                ref_uri.path = base_uri.path
              elsif path[0, 1] == '/'
                ref_uri.path = Pathname.new(path).cleanpath.to_s
              else
                ref_uri.join!(path)
              end

              ref_uri.fragment = fragment
            end

            ref_uri.fragment = '' if ref_uri.fragment.nil? || ref_uri.fragment.empty?
          end

          ref_uri
        end

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

        def strip_fragment(uri)
          parsed_uri = parse(uri)
          if parsed_uri.fragment.nil? || parsed_uri.fragment.empty?
            parsed_uri
          else
            parsed_uri.merge(fragment: '')
          end
        end

        # @param uri [Addressable::URI, String]
        # @return [String]
        def file_uri(uri)
          file_uri_cache.compute_if_absent(uri) do
            path = Addressable::URI.parse(uri).path

            Addressable::URI.convert_path(path)
          end
        end

        # @return [String]
        def unescape_uri(uri)
          Addressable::URI.unescape(uri)
        end

        # @param uri [Addressable::URI, String]
        # @return [String]
        def unescaped_path(uri)
          unescaped_path_cache.compute_if_absent(uri) do
            path = Addressable::URI.parse(uri).path

            unescape_uri(path)
          end
        end

        def clear_cache
          cache_mutex.synchronize do
            @unescaped_path_cache = Concurrent::Map.new
            @parse_cache = {}
            @normalize_cache = {}
          end
        end

        private

        # @!attribute cache_mutex
        #   @return [Mutex]
        attr_reader :cache_mutex

        # @!attribute unescaped_path_cache
        #   @return [Concurrent::Map<Addressable::URI, String>]
        attr_reader :unescaped_path_cache

        # @attribute file_uri_cache
        #   @return [Concurrent::Map<Addressable::URI, String>]
        attr_reader :file_uri_cache
      end
    end
  end
end
