require 'uri'
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
        base_schema = initialize_schema(base_schema[f]) #need to return a Schema instance for validation to work
        elsif base_schema.is_a?(Array)
          if base_schema[f.to_i].nil?
            raise JSON::Schema::SchemaError.new("Invalid fragment resolution for :fragment option")
          end
        base_schema = initialize_schema(base_schema[f.to_i])
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
      begin
        @base_schema.validate(@data,[],self,@validation_options)
        if @validation_options[:clear_cache] == true
          Validator.clear_cache
        end
        if @options[:errors_as_objects]
          return @errors.map{|e| e.to_hash}
        else
          return @errors.map{|e| e.to_string}
        end
      rescue JSON::Schema::ValidationError
        if @validation_options[:clear_cache] == true
          Validator.clear_cache
        end
        raise $!
      end
    end


    def load_ref_schema(parent_schema,ref)
      uri = URI.parse(ref)
      if uri.relative?
        uri = parent_schema.uri.clone

        # Check for absolute path
        path = ref.split("#")[0]

        # This is a self reference and thus the schema does not need to be re-loaded
        if path.nil? || path == ''
          return
        end

        if path && path[0,1] == '/'
          uri.path = Pathname.new(path).cleanpath.to_s
        else
          uri = parent_schema.uri.merge(path)
        end
        uri.fragment = ''
      end

      if Validator.schemas[uri.to_s].nil?
        schema = JSON::Schema.new(JSON::Validator.parse(open(uri.to_s).read), uri, @options[:version])
        Validator.add_schema(schema)
        build_schemas(schema)
      end
    end


    # Build all schemas with IDs, mapping out the namespace
    def build_schemas(parent_schema)
      # Build ref schemas if they exist
      if parent_schema.schema["$ref"]
        load_ref_schema(parent_schema, parent_schema.schema["$ref"])
      end
      if parent_schema.schema["extends"]
        if parent_schema.schema["extends"].is_a?(String)
          load_ref_schema(parent_schema, parent_schema.schema["extends"])
        elsif parent_schema.schema["extends"].is_a?(Array)
          parent_schema.schema["extends"].each do |type|
            handle_schema(parent_schema, type)
          end
        end
      end

      # handle validations that always contain schemas
      ["allOf", "anyOf", "oneOf", "not"].each do |key|
        if parent_schema.schema.has_key?(key)
          validations = parent_schema.schema[key]
          validations = [validations] unless validations.is_a?(Array)
          validations.each {|v| handle_schema(parent_schema, v) }
        end
      end

      # Check for schemas in union types
      ["type", "disallow"].each do |key|
        if parent_schema.schema[key] && parent_schema.schema[key].is_a?(Array)
          parent_schema.schema[key].each_with_index do |type,i|
            if type.is_a?(Hash)
              handle_schema(parent_schema, type)
            end
          end
        end
      end

      # "definitions" are schemas in V4
      if parent_schema.schema["definitions"]
        parent_schema.schema["definitions"].each do |k,v|
          handle_schema(parent_schema, v)
        end
      end

      # All properties are schemas
      if parent_schema.schema["properties"]
        parent_schema.schema["properties"].each do |k,v|
          handle_schema(parent_schema, v)
        end
      end
      if parent_schema.schema["patternProperties"]
        parent_schema.schema["patternProperties"].each do |k,v|
          handle_schema(parent_schema, v)
        end
      end

      # Items are always schemas
      if parent_schema.schema["items"]
        items = parent_schema.schema["items"].clone
        single = false
        if !items.is_a?(Array)
          items = [items]
          single = true
        end
        items.each_with_index do |item,i|
          handle_schema(parent_schema, item)
        end
      end

      # Convert enum to a ArraySet
      if parent_schema.schema["enum"] && parent_schema.schema["enum"].is_a?(Array)
        parent_schema.schema["enum"] = ArraySet.new(parent_schema.schema["enum"])
      end

      # Each of these might be schemas
      ["additionalProperties", "additionalItems", "dependencies", "extends"].each do |key|
        if parent_schema.schema[key].is_a?(Hash)
          handle_schema(parent_schema, parent_schema.schema[key])
        end
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
        @@schemas[schema.uri.to_s] = schema if @@schemas[schema.uri.to_s].nil?
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
        u = URI.parse(schema_uri)
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
            parser.parse(json)
          else
            raise JSON::Schema::JsonParseError.new("No supported JSON parsers found. The following parsers are suported:\n * yajl-ruby\n * json")
          end
        end
      end

      if !defined?(MultiJson)
        if begin
            Gem::Specification::find_by_name('json')
          rescue Gem::LoadError
            false
          rescue
            Gem.available?('json')
          end
          require 'json'
          @@available_json_backends << 'json'
          @@json_backend = 'json'
        end

        # Try force-loading json for rubies > 1.9.2
        begin
          require 'json'
          @@available_json_backends << 'json'
          @@json_backend = 'json'
        rescue LoadError
        end

        if begin
            Gem::Specification::find_by_name('yajl-ruby')
          rescue Gem::LoadError
            false
          rescue
            Gem.available?('yajl-ruby')
          end
          require 'yajl'
          @@available_json_backends << 'yajl'
          @@json_backend = 'yajl'
        end

        if @@json_backend == 'yajl'
          @@serializer = lambda{|o| Yajl::Encoder.encode(o) }
        else
          @@serializer = lambda{|o|
            YAML.dump(o)
          }
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

    if begin
        Gem::Specification::find_by_name('uuidtools')
      rescue Gem::LoadError
        false
      rescue
        Gem.available?('uuidtools')
      end
      require 'uuidtools'
      @@fake_uri_generator = lambda{|s| UUIDTools::UUID.sha1_create(UUIDTools::UUID_URL_NAMESPACE, s).to_s }
    else
      require 'json-schema/uri/uuid'
      @@fake_uri_generator = lambda{|s| JSON::Util::UUID.create_v5(s,JSON::Util::UUID::Nil).to_s }
    end

    def serialize schema
      if defined?(MultiJson)
        MultiJson.respond_to?(:dump) ? MultiJson.dump(schema) : MultiJson.encode(schema)
      else
        @@serializer.call(schema)
      end
    end

    def fake_uri schema
      @@fake_uri_generator.call(schema)
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
          schema_uri = URI.parse(fake_uri(schema))
          schema = JSON::Validator.parse(schema)
          if @options[:list] && @options[:fragment].nil?
            schema = schema_to_list(schema)
          end
          schema = JSON::Schema.new(schema,schema_uri,@options[:version])
          Validator.add_schema(schema)
        rescue
          # Build a uri for it
          schema_uri = URI.parse(schema)
          if schema_uri.relative?
            # Check for absolute path
            if schema[0,1] == '/'
              schema_uri = URI.parse("file://#{schema}")
            else
              schema_uri = URI.parse("file://#{Dir.pwd}/#{schema}")
            end
          end
          if Validator.schemas[schema_uri.to_s].nil?
            schema = JSON::Validator.parse(open(schema_uri.to_s).read)
            if @options[:list] && @options[:fragment].nil?
              schema = schema_to_list(schema)
            end
            schema = JSON::Schema.new(schema,schema_uri,@options[:version])
            Validator.add_schema(schema)
          else
            schema = Validator.schemas[schema_uri.to_s]
            if @options[:list] && @options[:fragment].nil?
              schema = schema_to_list(schema.schema)
              schema_uri = URI.parse(fake_uri(serialize(schema)))
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
        schema_uri = URI.parse(fake_uri(serialize(schema)))
        schema = JSON::Schema.new(schema,schema_uri,@options[:version])
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
        json_uri = URI.parse(data)
        if json_uri.relative?
          if data[0,1] == '/'
            json_uri = URI.parse("file://#{data}")
          else
            json_uri = URI.parse("file://#{Dir.pwd}/#{data}")
          end
        end
        data = JSON::Validator.parse(open(json_uri.to_s).read)
      elsif data.is_a?(String)
        begin
          data = JSON::Validator.parse(data)
        rescue
          begin
            json_uri = URI.parse(data)
            if json_uri.relative?
              if data[0,1] == '/'
                json_uri = URI.parse("file://#{data}")
              else
                json_uri = URI.parse("file://#{Dir.pwd}/#{data}")
              end
            end
            data = JSON::Validator.parse(open(json_uri.to_s).read)
          rescue
            # Silently discard the error - the data will not change
          end
        end
      end
      JSON::Schema.add_indifferent_access(data)
      data
    end

  end
end
