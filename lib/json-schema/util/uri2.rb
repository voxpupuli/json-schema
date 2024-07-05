# frozen_string_literal: true

require 'addressable'

module JSON
  module Util
    class URI2 < Addressable::URI
      class << self
        alias file_uri convert_path

        # @param uri [String, Addressable::URI
        # @return [String]
        def unescape_path(uri)
          parse(uri).unescape_path
        end

        # Strips the fragment from the URI.
        # @param uri [String, Addressable::URI]
        # @return [Addressable::URI]
        def strip_fragment(uri)
          parse(uri).without_fragment
        end
      end

      # Unencodes any percent encoded characters within a path component.
      #
      # @return [String]
      def unescape_path
        self.class.unescape_component(path)
      end

      # Strips the fragment from the URI.
      # @return [Addressable::URI] a new instance of URI without a fragment
      def without_fragment
        if fragment.nil? || fragment.empty?
          dup
        else
          merge(fragment: '')
        end
      end
    end
  end
end
