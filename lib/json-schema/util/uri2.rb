# frozen_string_literal: true

require 'addressable'

module JSON
  module Util
    class URI2 < Addressable::URI
      class << self
        # @param uri [String, Addressable::URI
        # @return [String]
        def unescape_path(uri)
          parse(uri).unescape_path
        end
      end

      # Unencodes any percent encoded characters within a path component.
      #
      # @return [String]
      def unescape_path
        self.class.unescape_component(path)
      end
    end
  end
end
