require 'open-uri'
require 'pathname'

module JSON
  class Schema
    # Raised by {JSON::Schema::Reader} when one of its settings indicate
    # a schema should not be readed.
    class ReadRefused < StandardError
      # @return [String] the requested schema location which was refused
      attr_reader :location

      # @return [Symbol] either +:uri+ or +:file+
      attr_reader :type

      def initialize(location, type)
        @location = location
        @type = type
        super("Read of #{type == :uri ? 'URI' : type} at #{location} refused!")
      end
    end

    # When an unregistered schema is encountered, the {JSON::Schema::Reader} is
    # used to fetch its contents and register it with the {JSON::Validator}.
    #
    # This default reader will read schemas from the filesystem or from a URI.
    class Reader
      # The behavior of the schema reader can be controlled by providing
      # callbacks to determine whether to permit reading referenced schemas.
      # The options +accept_uri+ and +accept_file+ should be procs which
      # accept a +URI+ or +Pathname+ object, and return a boolean value
      # indicating whether to read the referenced schema.
      #
      # URIs using the +file+ scheme will be normalized into +Pathname+ objects
      # and passed to the +accept_file+ callback.
      #
      # @param options [Hash]
      # @option options [Boolean, #call] accept_uri (true)
      # @option options [Boolean, #call] accept_file (true)
      #
      # @example Reject all unregistered schemas
      #   JSON::Validator.schema_reader = JSON::Schema::Reader.new(
      #     :accept_uri => false,
      #     :accept_file => false
      #   )
      #
      # @example Only permit URIs from certain hosts
      #   JSON::Validator.schema_reader = JSON::Schema::Reader.new(
      #     :accept_file => false,
      #     :accept_uri => proc { |uri| ['mycompany.com', 'json-schema.org'].include?(uri.host) }
      #   )
      def initialize(options = {})
        @accept_uri = options.fetch(:accept_uri, true)
        @accept_file = options.fetch(:accept_file, true)
      end

      # @param location [#to_s] The location from which to read the schema
      # @return [JSON::Schema]
      # @raise [JSON::Schema::ReadRefused] if +accept_uri+ or +accept_file+
      #   indicated the schema could not be read
      # @raise [JSON::Schema::ParseError] if the schema was not a valid JSON object
      def read(location)
        uri  = JSON::Util::URI.parse(location.to_s)
        body = if uri.scheme.nil? || uri.scheme == 'file'
                 uri = JSON::Util::URI.file_uri(uri)
                 read_file(Pathname.new(uri.path).expand_path)
               else
                 read_uri(uri)
               end

        JSON::Schema.new(JSON::Validator.parse(body), uri)
      end

      # @param uri [Addressable::URI]
      # @return [Boolean]
      def accept_uri?(uri)
        if @accept_uri.respond_to?(:call)
          @accept_uri.call(uri)
        else
          @accept_uri
        end
      end

      # @param pathname [Pathname]
      # @return [Boolean]
      def accept_file?(pathname)
        if @accept_file.respond_to?(:call)
          @accept_file.call(pathname)
        else
          @accept_file
        end
      end

      private

      def read_uri(uri)
        if accept_uri?(uri)
          open(uri.to_s).read
        else
          raise JSON::Schema::ReadRefused.new(uri.to_s, :uri)
        end
      end

      def read_file(pathname)
        if accept_file?(pathname)
          File.read(JSON::Util::URI.unescaped_path(pathname.to_s))
        else
          raise JSON::Schema::ReadRefused.new(pathname.to_s, :file)
        end
      end
    end
  end
end
