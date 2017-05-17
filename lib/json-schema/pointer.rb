require 'addressable/uri'

module JSON
  class Schema
    class Pointer
      class Error < JSON::Schema::SchemaError
      end
      class PointerSyntaxError < Error
      end
      class ReferenceError < Error
      end

      def self.parse_fragment(fragment)
        fragment = Addressable::URI.unescape(fragment)
        match = fragment.match(/\A#/)
        if match
          parse_pointer(match.post_match)
        else
          raise(PointerSyntaxError, "Invalid fragment syntax in #{fragment.inspect}: fragment must begin with #")
        end
      end

      def self.parse_pointer(pointer_string)
        tokens = pointer_string.split('/', -1).map! do |piece|
          piece.gsub('~1', '/').gsub('~0', '~')
        end
        if tokens[0] == ''
          tokens[1..-1]
        elsif tokens.empty?
          tokens
        else
          raise(PointerSyntaxError, "Invalid pointer syntax in #{pointer_string.inspect}: pointer must begin with /")
        end
      end

      def initialize(type, representation)
        @type = type
        if type == :reference_tokens
          reference_tokens = representation
        elsif type == :fragment
          reference_tokens = self.class.parse_fragment(representation)
        elsif type == :pointer
          reference_tokens = self.class.parse_pointer(representation)
        else
          raise ArgumentError, "invalid initialization type: #{type.inspect} with representation #{representation.inspect}"
        end
        @reference_tokens = reference_tokens.map(&:freeze).freeze
      end

      attr_reader :reference_tokens

      def evaluate(document)
        reference_tokens.inject(document) do |value, token|
          if value.is_a?(Array)
            if token.is_a?(String) && token =~ /\A\d|[1-9]\d+\z/
              token = token.to_i
            end
            unless token.is_a?(Integer)
              raise(ReferenceError, "Invalid resolution for #{to_s}: #{token.inspect} is not an integer and cannot be resolved in array #{value.inspect}")
            end
            unless (0...value.size).include?(token)
              raise(ReferenceError, "Invalid resolution for #{to_s}: #{token.inspect} is not a valid index of #{value.inspect}")
            end
          elsif value.is_a?(Hash)
            unless value.key?(token)
              raise(ReferenceError, "Invalid resolution for #{to_s}: #{token.inspect} is not a valid key of #{value.inspect}")
            end
          else
            raise(ReferenceError, "Invalid resolution for #{to_s}: #{token.inspect} cannot be resolved in #{value.inspect}")
          end
          value[token]
        end
      end

      # the pointer string representation of this Pointer
      def pointer
        reference_tokens.map { |t| '/' + t.to_s.gsub('~', '~0').gsub('/', '~1') }.join('')
      end

      # the fragment string representation of this Pointer
      def fragment
        '#' + Addressable::URI.escape(pointer)
      end

      def to_s
        "#<#{self.class.name} #{@type} = #{representation_s}>"
      end

      private

      def representation_s
        if @type == :fragment
          fragment
        elsif @type == :pointer
          pointer
        else
          reference_tokens.inspect
        end
      end
    end
  end
end
