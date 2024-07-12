# frozen_string_literal: true

require 'addressable/uri'

module JSON
  module Util
    # @api private
    class URI < Addressable::URI
      SUPPORTED_PROTOCOLS = %w(http https ftp tftp sftp ssh svn+ssh telnet nntp gopher wais ldap prospero)

      class << self
        alias unescape_uri unescape

        # @param uri [String, Addressable::URI]
        # @return [Addressable::URI, nil]
        def parse(uri)
          super(uri)
        rescue Addressable::URI::InvalidURIError => e
          raise JSON::Schema::UriError, e.message
        end

        # @param uri [String, Addressable::URI]
        # @return [Addressable::URI, nil]
        def file_uri(uri)
          convert_path(parse(uri).path)
        end

        # @param uri [String, Addressable::URI
        # @return [String]
        def unescaped_path(uri)
          parse(uri).unescaped_path
        end

        # Strips the fragment from the URI.
        # @param uri [String, Addressable::URI]
        # @return [Addressable::URI]
        def strip_fragment(uri)
          parse(uri).strip_fragment
        end

        # @param uri [String, Addressable::URI]
        # @return [Addressable::URI]
        def normalized_uri(uri, base_path = Dir.pwd)
          parse(uri).normalized_uri(base_path)
        end

        # Normalizes the reference URI based on the provided base URI
        #
        # @param ref [String, Addressable::URI]
        # @param base [String, Addressable::URI]
        # @return [Addressable::URI]
        def normalize_ref(ref, base)
          parse(ref).normalize_ref(base)
        end

        def absolutize_ref(ref, base)
          parse(ref).absolutize_ref(base)
        end
      end

      # Unencodes any percent encoded characters within a path component.
      #
      # @return [String]
      def unescaped_path
        self.class.unescape_component(path)
      end

      # Strips the fragment from the URI.
      # @return [Addressable::URI] a new instance of URI without a fragment
      def strip_fragment
        if fragment.nil? || fragment.empty?
          self
        else
          merge(fragment: '')
        end
      end

      # Normalizes the URI based on the provided base path.
      #
      # @param base_path [String] the base path to use for relative URIs. Defaults to the current working directory.
      # @return [Addressable::URI] the normalized URI or nil
      def normalized_uri(base_path = Dir.pwd)
        if relative?
          if path[0, 1] == '/'
            self.class.file_uri(self)
          else
            self.class.file_uri(File.join(base_path, self))
          end
        else
          self
        end
      end

      # @param base [Addressable::URI, String]
      # @return [Addressable::URI]
      def normalize_ref(base)
        base_uri = self.class.parse(base)
        defer_validation do
          if relative?
            # Check for absolute path
            path, fragment = to_s.split('#')
            merge!(base_uri)

            if path.nil? || path == ''
              self.path = base_uri.path
            elsif path[0, 1] == '/'
              self.path = Pathname.new(path).cleanpath.to_s
            else
              join!(path)
            end

            self.fragment = fragment
          end

          self.fragment = '' if self.fragment.nil? || self.fragment.empty?
        end

        self
      end

      # @param base [Addressable::URI, String]
      # @return [Addressable::URI]
      def absolutize_ref(base)
        ref = strip_fragment
        if ref.absolute?
          ref
        else
          self.class.strip_fragment(base).join(ref.path).normalized_uri
        end
      end
    end
  end
end
