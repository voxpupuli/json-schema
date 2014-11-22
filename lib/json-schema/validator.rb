require 'addressable/uri'
require 'open-uri'
require 'pathname'
require 'bigdecimal'
require 'digest/sha1'
require 'date'
require 'thread'
require 'yaml'

require 'json-schema/errors/schema_error'
require 'json-schema/errors/json_parse_error'

module JSON

  class Validator

    @@schemas = {}
    @@cache_schemas = false
    @@default_opts = {
      :list => false,
      :version => nil,
      :validate_schema => false,
      :record_errors => false,
      :errors_as_objects => false,
      :insert_defaults => false,
      :clear_cache => true,
      :strict => false
    }
    @@validators = {}
    @@default_validator = nil
    @@available_json_backends = []
    @@json_backend = nil
    @@serializer = nil
    @@mutex = Mutex.new

    def initialize(schema_data, data, opts={})
      @options = @@default_opts.clone.merge(opts)
      @errors = []

      validator = JSON::Validator.validator_for_name(@options[:version])
      @options[:version] = validator

      @validation_options = @options[:record_errors] ? {:record_errors => true} : {}
      @validation_options[:insert_defaults] = true if @options[:insert_defaults]
      @validation_options[:strict] = true if @options[:strict] == true

      @@mutex.synchronize { @base_schema = initialize_schema(schema_data) }
      @original_data = data
      @data = initialize_data(data)
      @@mutex.synchronize { build_schemas(@base_schema) }

      # validate the schema, if requested
      if @options[:validate_schema]
        begin
          if @base_schema.schema["$schema"]
            base_validator = JSON::Validator.validator_for_name(@base_schema.schema["$schema"])
          end
          metaschema = base_validator ? base_validator.metaschema : validator.metaschema
          # Don't clear the cache during metaschema validation!
          meta_validator = JSON::Validator.new(metaschema, @base_schema.schema, {:clear_cache => false})
          meta_validator.validate
        rescue JSON::Schema::ValidationError, JSON::Schema::SchemaError
          raise $!
        end
      end

      # If the :fragment option is set, try and validate against the fragment
      if opts[:fragment]
        @base_schema = schema_from_fragment(@base_schema, opts[:fragment])
      end
    end

    def schema_from_fragment(base_schema, fragment)
      schema_uri = base_schema.uri
      fragments = fragment.split("/")

      # ensure the first element was a hash, per the fragment spec
      if fragments.shift != "#"
        raise JSON::Schema::SchemaError.new("Invalid fragment syntax in :fragment option")
      end

      fragments.each do |f|
        if base_schema.is_a?(JSON::Schema) #test if fragment is a JSON:Schema instance
          if !base_schema.schema.has_key?(f)
            raise JSON::Schema::SchemaError.new("Invalid fragment resolution for :fragment option")
          end
          base_schema = base_schema.schema[f]
        elsif base_schema.is_a?(Hash)
          if !base_schema.has_key?(f)
            raise JSON::Schema::SchemaError.new("Invalid fragment resolution for :fragment option")
          end
          base_schema = JSON::Schema.new(base_schema[f],schema_uri,@options[:version])
        elsif base_schema.is_a?(Array)
          if base_schema[f.to_i].nil?
            raise JSON::Schema::SchemaError.new("Invalid fragment resolution for :fragment option")
          end
          base_schema = JSON::Schema.new(base_schema[f.to_i],schema_uri,@options[:version])
        else
          raise JSON::Schema::SchemaError.new("Invalid schema encountered when resolving :fragment option")
        end
      end
      if @options[:list] #check if the schema is validating a list
        base_schema.schema = schema_to_list(base_schema.schema)
      end
      base_schema
    end

    # Run a simple true/false validation of data against a schema
    def validate()
      @base_schema.validate(@data,[],self,@validation_options)
      if @options[:errors_as_objects]
        return @errors.map{|e| e.to_hash}
      else
        return @errors.map{|e| e.to_string}
      end
    ensure
      if @validation_options[:clear_cache] == true
        Validator.clear_cache
      end
      if @validation_options[:insert_defaults]
        JSON::Validator.merge_missing_values(@data, @original_data)
      end
    end

    def load_ref_schema(parent_schema, ref)
      schema_uri = absolutize_ref_uri(ref, parent_schema.uri)

      return true if self.class.schema_loaded?(schema_uri)

      schema_data = self.class.parse(custom_open(schema_uri))
      schema = JSON::Schema.new(schema_data, schema_uri, @options[:version])
      self.class.add_schema(schema)
      build_schemas(schema)
    end

    def absolutize_ref_uri(ref, parent_schema_uri)
      ref_uri = Addressable::URI.parse(ref)

      return ref_uri if ref_uri.absolute?
      # This is a self reference and thus the schema does not need to be re-loaded
      return parent_schema_uri if ref_uri.path.empty?

      uri = parent_schema_uri.clone
      uri.fragment = ''
      normalized_uri(uri.join(ref_uri.path))
    end

    # Build all schemas with IDs, mapping out the namespace
    def build_schemas(parent_schema)
      schema = parent_schema.schema

      # Build ref schemas if they exist
      if schema["$ref"]
        load_ref_schema(parent_schema, schema["$ref"])
      end

      case schema["extends"]
      when String
        load_ref_schema(parent_schema, schema["extends"])
      when Array
        schema['extends'].each do |type|
          handle_schema(parent_schema, type)
        end
      end

      # Check for schemas in union types
      ["type", "disallow"].each do |key|
        if schema[key].is_a?(Array)
          schema[key].each do |type|
            if type.is_a?(Hash)
              handle_schema(parent_schema, type)
            end
          end
        end
      end

      # Schema properties whose values are objects, the values of which
      # are themselves schemas.
      %w[definitions properties patternProperties].each do |key|
        next unless value = schema[key]
        value.each do |k, inner_schema|
          handle_schema(parent_schema, inner_schema)
        end
      end

      # Schema properties whose values are themselves schemas.
      %w[additionalProperties additionalItems dependencies extends].each do |key|
        next unless schema[key].is_a?(Hash)
        handle_schema(parent_schema, schema[key])
      end

      # Schema properties whose values may be an array of schemas.
      %w[allOf anyOf oneOf not].each do |key|
        next unless value = schema[key]
        Array(value).each do |inner_schema|
          handle_schema(parent_schema, inner_schema)
        end
      end

      # Items are always schemas
      if schema["items"]
        items = schema["items"].clone
        items = [items] unless items.is_a?(Array)

        items.each do |item|
          handle_schema(parent_schema, item)
        end
      end

      # Convert enum to a ArraySet
      if schema["enum"].is_a?(Array)
        schema["enum"] = ArraySet.new(schema["enum"])
      end

    end

    # Either load a reference schema or create a new schema
    def handle_schema(parent_schema, obj)
      if obj.is_a?(Hash)
        schema_uri = parent_schema.uri.clone
        schema = JSON::Schema.new(obj,schema_uri,parent_schema.validator)
        if obj['id']
          Validator.add_schema(schema)
        end
        build_schemas(schema)
      end
    end

    def validation_error(error)
      @errors.push(error)
    end

    def validation_errors
      @errors
    end


    class << self
      def validate(schema, data,opts={})
        begin
          validator = JSON::Validator.new(schema, data, opts)
          validator.validate
          return true
        rescue JSON::Schema::ValidationError, JSON::Schema::SchemaError
          return false
        end
      end

      def validate_json(schema, data, opts={})
        validate(schema, data, opts.merge(:json => true))
      end

      def validate_uri(schema, data, opts={})
        validate(schema, data, opts.merge(:uri => true))
      end

      def validate!(schema, data,opts={})
        validator = JSON::Validator.new(schema, data, opts)
        validator.validate
        return true
      end
      alias_method 'validate2', 'validate!'

      def validate_json!(schema, data, opts={})
        validate!(schema, data, opts.merge(:json => true))
      end

      def validate_uri!(schema, data, opts={})
        validate!(schema, data, opts.merge(:uri => true))
      end

      def fully_validate(schema, data, opts={})
        opts[:record_errors] = true
        validator = JSON::Validator.new(schema, data, opts)
        validator.validate
      end

      def fully_validate_schema(schema, opts={})
        data = schema
        schema = JSON::Validator.validator_for_name(opts[:version]).metaschema
        fully_validate(schema, data, opts)
      end

      def fully_validate_json(schema, data, opts={})
        fully_validate(schema, data, opts.merge(:json => true))
      end

      def fully_validate_uri(schema, data, opts={})
        fully_validate(schema, data, opts.merge(:uri => true))
      end

      def clear_cache
        @@schemas = {} if @@cache_schemas == false
      end

      def schemas
        @@schemas
      end

      def add_schema(schema)
        @@schemas[schema.uri.to_s] ||= schema
      end

      def schema_for_uri(uri)
        @@schemas[uri.to_s]
      end

      def schema_loaded?(schema_uri)
        @@schemas.has_key?(schema_uri.to_s)
      end

      def cache_schemas=(val)
        warn "[DEPRECATION NOTICE] Schema caching is now a validation option. Schemas will still be cached if this is set to true, but this method will be removed in version >= 3. Please use the :clear_cache validation option instead."
        @@cache_schemas = val == true ? true : false
      end

      def validators
        @@validators
      end

      def default_validator
        @@default_validator
      end

      def validator_for_uri(schema_uri)
        return default_validator unless schema_uri
        u = Addressable::URI.parse(schema_uri)
        validator = validators["#{u.scheme}://#{u.host}#{u.path}"]
        if validator.nil?
          raise JSON::Schema::SchemaError.new("Schema not found: #{schema_uri}")
        else
          validator
        end
      end

      def validator_for_name(schema_name)
        return default_validator unless schema_name
        validator = validators_for_names([schema_name]).first
        if validator.nil?
          raise JSON::Schema::SchemaError.new("The requested JSON schema version is not supported")
        else
          validator
        end
      end

      alias_method :validator_for, :validator_for_uri

      def register_validator(v)
        @@validators["#{v.uri.scheme}://#{v.uri.host}#{v.uri.path}"] = v
      end

      def register_default_validator(v)
        @@default_validator = v
      end

      def register_format_validator(format, validation_proc, versions = ["draft1", "draft2", "draft3", "draft4"])
        custom_format_validator = JSON::Schema::CustomFormat.new(validation_proc)
        validators_for_names(versions).each do |validator|
          validator.formats[format.to_s] = custom_format_validator
        end
      end

      def deregister_format_validator(format, versions = ["draft1", "draft2", "draft3", "draft4"])
        validators_for_names(versions).each do |validator|
          validator.formats[format.to_s] = validator.default_formats[format.to_s]
        end
      end

      def restore_default_formats(versions = ["draft1", "draft2", "draft3", "draft4"])
        validators_for_names(versions).each do |validator|
          validator.formats = validator.default_formats.clone
        end
      end

      def json_backend
        if defined?(MultiJson)
          MultiJson.respond_to?(:adapter) ? MultiJson.adapter : MultiJson.engine
        else
          @@json_backend
        end
      end

      def json_backend=(backend)
        if defined?(MultiJson)
          backend = backend == 'json' ? 'json_gem' : backend
          MultiJson.respond_to?(:use) ? MultiJson.use(backend) : MultiJson.engine = backend
        else
          backend = backend.to_s
          if @@available_json_backends.include?(backend)
            @@json_backend = backend
          else
            raise JSON::Schema::JsonParseError.new("The JSON backend '#{backend}' could not be found.")
          end
        end
      end

      def parse(s)
        if defined?(MultiJson)
          MultiJson.respond_to?(:adapter) ? MultiJson.load(s) : MultiJson.decode(s)
        else
          case @@json_backend.to_s
          when 'json'
            JSON.parse(s)
          when 'yajl'
            json = StringIO.new(s)
            parser = Yajl::Parser.new
            parser.parse(json) or raise JSON::Schema::JsonParseError.new("The JSON could not be parsed by yajl")
          else
            raise JSON::Schema::JsonParseError.new("No supported JSON parsers found. The following parsers are suported:\n * yajl-ruby\n * json")
          end
        end
      end

      def merge_missing_values(source, destination)
        case destination
        when Hash
          source.each do |key, source_value|
            destination_value = destination[key] || destination[key.to_sym]
            if destination_value.nil?
              destination[key] = source_value
            else
              merge_missing_values(source_value, destination_value)
            end
          end
        when Array
          source.each_with_index do |source_value, i|
            destination_value = destination[i]
            merge_missing_values(source_value, destination_value)
          end
        end
      end

      if !defined?(MultiJson)
        if Gem::Specification::find_all_by_name('json').any?
          require 'json'
          @@available_json_backends << 'json'
          @@json_backend = 'json'
        else
          # Try force-loading json for rubies > 1.9.2
          begin
            require 'json'
            @@available_json_backends << 'json'
            @@json_backend = 'json'
          rescue LoadError
          end
        end


        if Gem::Specification::find_all_by_name('yajl-ruby').any?
          require 'yajl'
          @@available_json_backends << 'yajl'
          @@json_backend = 'yajl'
        end

        if @@json_backend == 'yajl'
          @@serializer = lambda{|o| Yajl::Encoder.encode(o) }
        else
          @@serializer = lambda{|o| YAML.dump(o) }
        end
      end

      private

      def validators_for_names(names)
        names.map! { |name| name.to_s }
        validators.reduce([]) do |memo, (_, validator)|
          memo.tap { |m| m << validator if (validator.names & names).any? }
        end
      end
    end

    private

    if Gem::Specification::find_all_by_name('uuidtools').any?
      require 'uuidtools'
      @@fake_uuid_generator = lambda{|s| UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, s).to_s }
    else
      require 'json-schema/util/uuid'
      @@fake_uuid_generator = lambda{|s| JSON::Util::UUID.create_v5(s,JSON::Util::UUID::Nil).to_s }
    end

    def serialize schema
      if defined?(MultiJson)
        MultiJson.respond_to?(:dump) ? MultiJson.dump(schema) : MultiJson.encode(schema)
      else
        @@serializer.call(schema)
      end
    end

    def fake_uuid schema
      @@fake_uuid_generator.call(schema)
    end

    def schema_to_list(schema)
      new_schema = {"type" => "array", "items" => schema}
      if !schema["$schema"].nil?
        new_schema["$schema"] = schema["$schema"]
      end

      new_schema
    end

    def initialize_schema(schema)
      if schema.is_a?(String)
        begin
          # Build a fake URI for this
          schema_uri = Addressable::URI.parse(fake_uuid(schema))
          schema = JSON::Validator.parse(schema)
          if @options[:list] && @options[:fragment].nil?
            schema = schema_to_list(schema)
          end
          schema = JSON::Schema.new(schema,schema_uri,@options[:version])
          Validator.add_schema(schema)
        rescue
          # Build a uri for it
          schema_uri = normalized_uri(schema)
          if !self.class.schema_loaded?(schema_uri)
            schema = JSON::Validator.parse(custom_open(schema_uri))
            schema = JSON::Schema.stringify(schema)
            if @options[:list] && @options[:fragment].nil?
              schema = schema_to_list(schema)
            end
            schema = JSON::Schema.new(schema,schema_uri,@options[:version])
            Validator.add_schema(schema)
          else
            schema = self.class.schema_for_uri(schema_uri)
            if @options[:list] && @options[:fragment].nil?
              schema = schema_to_list(schema.schema)
              schema_uri = Addressable::URI.parse(fake_uuid(serialize(schema)))
              schema = JSON::Schema.new(schema, schema_uri, @options[:version])
              Validator.add_schema(schema)
            end
            schema
          end
        end
      elsif schema.is_a?(Hash)
        if @options[:list] && @options[:fragment].nil?
          schema = schema_to_list(schema)
        end
        schema_uri = Addressable::URI.parse(fake_uuid(serialize(schema)))
        schema = JSON::Schema.stringify(schema)
        schema = JSON::Schema.new(schema,schema_uri,@options[:version])
        Validator.add_schema(schema)
      elsif schema.is_a?(JSON::Schema)
        Validator.add_schema(schema)
      else
        raise "Invalid schema - must be either a string or a hash"
      end

      schema
    end


    def initialize_data(data)
      if @options[:json]
        data = JSON::Validator.parse(data)
      elsif @options[:uri]
        json_uri = normalized_uri(data)
        data = JSON::Validator.parse(custom_open(json_uri))
      elsif data.is_a?(String)
        begin
          data = JSON::Validator.parse(data)
        rescue
          begin
            json_uri = normalized_uri(data)
            data = JSON::Validator.parse(custom_open(json_uri))
          rescue
            # Silently discard the error - the data will not change
          end
        end
      end
      JSON::Schema.stringify(data)
    end

    def custom_open(uri)
      if uri.absolute? && uri.scheme != 'file'
        open(uri.to_s).read
      else
        File.read(Addressable::URI.unescape(uri.path))
      end
    end

    def normalized_uri(data)
      uri = Addressable::URI.parse(data)
      # Check for absolute path
      if uri.relative?
        data = data.to_s
        data = "#{Dir.pwd}/#{data}" if data[0,1] != '/'
        uri = Addressable::URI.convert_path(data)
      end
      uri
    end
  end
end
