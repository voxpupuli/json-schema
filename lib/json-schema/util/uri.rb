module JSON
  module Util
    module URI
      SUPPORTED_PROTOCOLS = %w(http https ftp tftp sftp ssh svn+ssh telnet nntp gopher wais ldap prospero)

      def self.normalized_uri(uri, base_path = Dir.pwd)
        @normalize_cache ||= {}
        normalized_uri = @normalize_cache[uri]

        if !normalized_uri
          normalized_uri = parse(uri)
          # Check for absolute path
          if normalized_uri.relative?
            data = normalized_uri
            data = File.join(base_path, data) if data.path[0,1] != "/"
            normalized_uri = Addressable::URI.convert_path(data)
          end
          @normalize_cache[uri] = normalized_uri.freeze
        end

        normalized_uri
      end

      def self.parse(uri)
        if uri.is_a?(Addressable::URI)
          return uri.dup
        else
          @parse_cache ||= {}
          parsed_uri = @parse_cache[uri]
          if parsed_uri
            parsed_uri.dup
          else
            @parse_cache[uri] = Addressable::URI.parse(uri)
          end
        end
      end

      def self.strip_fragment(uri)
        parsed_uri = parse(uri)
        if parsed_uri.fragment.nil? || parsed_uri.fragment.empty?
          parsed_uri
        else
          parsed_uri.merge(:fragment => "")
        end
      end
    end
  end
end
