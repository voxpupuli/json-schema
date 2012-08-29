require 'uri'
require 'open-uri'
require 'pathname'
require 'bigdecimal'
require 'digest/sha1'
require 'date'

module JSON

  class Schema
    class ValidationError < StandardError
      attr_accessor :fragments, :schema, :failed_attribute, :sub_errors

      def initialize(message, fragments, failed_attribute, schema)
        @fragments = fragments.clone
        @schema = schema
        @sub_errors = []
        @failed_attribute = failed_attribute
        message = "#{message} in schema #{schema.uri}"
        super(message)
      end
      
      def to_string
        if @sub_errors.empty?
          message
        else
          full_message = message + "\n The schema specific errors were:\n"
          @sub_errors.each{|e| full_message = full_message + " - " + e.to_string + "\n"}
          full_message
        end
      end
      
      def to_hash
        base = {:schema => @schema.uri, :fragment => ::JSON::Schema::Attribute.build_fragment(fragments), :message => message, :failed_attribute => @failed_attribute.to_s.split(":").last.split("Attribute").first}
        if !@sub_errors.empty?
          base[:errors] = @sub_errors.map{|e| e.to_hash}
        end
        base
      end
    end

    class SchemaError < StandardError
    end

    class JsonParseError < StandardError
    end

    class Attribute
      def self.validate(current_schema, data, fragments, validator, options = {})
      end

      def self.build_fragment(fragments)
        "#/#{fragments.join('/')}"
      end

      def self.validation_error(message, fragments, current_schema, failed_attribute, record_errors)
        error = ValidationError.new(message, fragments, failed_attribute, current_schema)
        if record_errors
          ::JSON::Validator.validation_error(error)
        else
          raise error
        end
      end
      
      def self.validation_errors
        ::JSON::Validator.validation_errors
      end
    end

    class Validator
      attr_accessor :attributes, :uri

      def initialize()
        @attributes = {}
        @uri = nil
      end

      def extend_schema_definition(schema_uri)
        u = URI.parse(schema_uri)
        validator = JSON::Validator.validators["#{u.scheme}://#{u.host}#{u.path}"]
        if validator.nil?
          raise SchemaError.new("Schema not found: #{u.scheme}://#{u.host}#{u.path}")
        end
        @attributes.merge!(validator.attributes)
      end

      def to_s
        "#{@uri.scheme}://#{uri.host}#{uri.path}"
      end

      def validate(current_schema, data, fragments, options = {})
        current_schema.schema.each do |attr_name,attribute|
          if @attributes.has_key?(attr_name.to_s)
            @attributes[attr_name.to_s].validate(current_schema, data, fragments, self, options)
          end
        end
        data
      end
    end
  end


  class Validator

    @@schemas = {}
    @@cache_schemas = false
    @@default_opts = {
      :list => false,
      :version => nil,
      :validate_schema => false,
      :record_errors => false,
      :errors_as_objects => false
    }
    @@validators = {}
    @@default_validator = nil
    @@available_json_backends = []
    @@json_backend = nil
    @@errors = []
    @@serializer = nil

    def self.version_string_for(version)
      # I'm not a fan of this, but it's quick and dirty to get it working for now
      return "draft-03" unless version
      case version.to_s
      when "draft3"
        "draft-03"
      when "draft2"
        "draft-02"
      when "draft1"
        "draft-01"
      else
        raise JSON::Schema::SchemaError.new("The requested JSON schema version is not supported")
      end
    end

    def self.metaschema_for(version_string)
      File.join(Pathname.new(File.dirname(__FILE__)).parent.parent, "resources", "#{version_string}.json").to_s
    end

    def initialize(schema_data, data, opts={})
      @options = @@default_opts.clone.merge(opts)

      # I'm not a fan of this, but it's quick and dirty to get it working for now
      version_string = "draft-03"
      if @options[:version]
        version_string = @options[:version] = self.class.version_string_for(@options[:version])
        u = URI.parse("http://json-schema.org/#{@options[:version]}/schema#")
        validator = JSON::Validator.validators["#{u.scheme}://#{u.host}#{u.path}"]
        @options[:version] = validator
      end

      @validation_options = @options[:record_errors] ? {:record_errors => true} : {}
      
      # validate the schema, if requested
      if @options[:validate_schema]
        begin
          meta_validator = JSON::Validator.new(self.class.metaschema_for(version_string), schema_data)
          meta_validator.validate
        rescue JSON::Schema::ValidationError, JSON::Schema::SchemaError
          raise $!
        end
      end
      
      @base_schema = initialize_schema(schema_data)
      @data = initialize_data(data)
      build_schemas(@base_schema)
    end


    # Run a simple true/false validation of data against a schema
    def validate()
      begin
        Validator.clear_errors
        @base_schema.validate(@data,[],@validation_options)
        Validator.clear_cache
        if @options[:errors_as_objects]
          @@errors.map{|e| e.to_hash}
        else
          @@errors.map{|e| e.to_string}
        end
      rescue JSON::Schema::ValidationError
        Validator.clear_cache
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
        begin
          schema = JSON::Schema.new(JSON::Validator.parse(open(uri.to_s).read), uri, @options[:version])
          Validator.add_schema(schema)
          build_schemas(schema)
        rescue JSON::ParserError
          # Don't rescue this error, we want JSON formatting issues to bubble up
          raise $!
        rescue Exception
          # Failures will occur when this URI cannot be referenced yet. Don't worry about it,
          # the proper error will fall out if the ref isn't ever defined
        end
      end
    end


    # Build all schemas with IDs, mapping out the namespace
    def build_schemas(parent_schema)
      # Build ref schemas if they exist
      if parent_schema.schema["$ref"]
        load_ref_schema(parent_schema, parent_schema.schema["$ref"])
      end
      if parent_schema.schema["extends"] && parent_schema.schema["extends"].is_a?(String)
        load_ref_schema(parent_schema, parent_schema.schema["extends"])
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

      # All properties are schemas
      if parent_schema.schema["properties"]
        parent_schema.schema["properties"].each do |k,v|
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
        schema = JSON::Schema.new(obj,schema_uri,@options[:version])
        if obj['id']
          Validator.add_schema(schema)
        end
        build_schemas(schema)
      end
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
        schema = metaschema_for(version_string_for(opts[:version]))
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

      def clear_errors
        @@errors = []
      end

      def validation_error(error)
        @@errors.push(error)
      end
      
      def validation_errors
        @@errors
      end

      def schemas
        @@schemas
      end

      def add_schema(schema)
        @@schemas[schema.uri.to_s] = schema if @@schemas[schema.uri.to_s].nil?
      end

      def cache_schemas=(val)
        @@cache_schemas = val == true ? true : false
      end

      def validators
        @@validators
      end

      def default_validator
        @@default_validator
      end

      def register_validator(v)
        @@validators[v.to_s] = v
      end

      def register_default_validator(v)
        @@default_validator = v
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
          @@serializer = lambda{|o| Marshal.dump(o) }  	  
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
      require 'uri/uuid'
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

    def initialize_schema(schema)
      if schema.is_a?(String)
        begin
          # Build a fake URI for this
          schema_uri = URI.parse(fake_uri(schema))
          schema = JSON::Validator.parse(schema)
          if @options[:list]
            schema = {"type" => "array", "items" => schema}
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
            if @options[:list]
              schema = {"type" => "array", "items" => schema}
            end
            schema = JSON::Schema.new(schema,schema_uri,@options[:version])
            Validator.add_schema(schema)
          else
            schema = Validator.schemas[schema_uri.to_s]
          end
        end
      elsif schema.is_a?(Hash)
        if @options[:list]
          schema = {"type" => "array", "items" => schema}
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
      data
    end

  end
end
