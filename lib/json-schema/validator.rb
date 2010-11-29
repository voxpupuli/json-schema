require 'uri'
require 'open-uri'
require 'pathname'
require 'bigdecimal'

module JSON
    class Validator
    
    def initialize(schema_data, data)
      @schemas = {}
      @base_schema = initialize_schema(schema_data)
      @data = initialize_data(data)
      @schemas[@base_schema.uri.to_s] = @base_schema
      
      build_schemas(@base_schema)
    end  
    
    
    def validate()
      validate_schema(@base_schema, @data)
    end
    
    
    def validate_schema(current_schema, data)
      valid = true # Actually doing true/false on validation. Return at any point if invalid
      
      # Check the type
      if current_schema.schema['type']
        valid = validate_type(current_schema.schema['type'],data,current_schema)
      end
      return valid if !valid
      if current_schema.schema['disallow']
        valid = !validate_type(current_schema.schema['disallow'],data,current_schema)
      end
      return valid if !valid
      
      # Check the values
      if current_schema.schema['minimum'] && data.is_a?(Numeric)
        valid = current_schema.schema['exclusiveMinimum'] ? data > current_schema.schema['minimum'] : data >= current_schema.schema['minimum']
      end
      return valid if !valid
      
      if current_schema.schema['maximum'] && data.is_a?(Numeric)
        valid = current_schema.schema['exclusiveMaximum'] ? data < current_schema.schema['maximum'] : data <= current_schema.schema['maximum']
      end
      return valid if !valid
      
      if current_schema.schema['minItems'] && data.is_a?(Array)
        valid = data.nitems >= current_schema.schema['minItems']
      end
      return valid if !valid
      
      if current_schema.schema['maxItems'] && data.is_a?(Array)
        valid = data.nitems <= current_schema.schema['maxItems']
      end
      return valid if !valid
      
      if current_schema.schema['uniqueItems'] && data.is_a?(Array)
        d = data.clone
        dupes = d.uniq!
        valid = dupes.nil?
      end
      return valid if !valid
      
      if current_schema.schema['pattern'] && data.is_a?(String)
        r = Regexp.new(current_schema.schema['pattern'])
        valid = !(r.match(data)).nil?
      end
      return valid if !valid
      
      if current_schema.schema['minLength'] && data.is_a?(String)
        valid = data.length >= current_schema.schema['minLength']
      end
      return valid if !valid
      
      if current_schema.schema['maxLength'] && data.is_a?(String)
        valid = data.length <= current_schema.schema['maxLength']
      end
      return valid if !valid
      
      if current_schema.schema['divisibleBy'] && data.is_a?(Numeric)
        if current_schema.schema['divisibleBy'] == 0 || current_schema.schema['divisibleBy'] == 0.0
          return false
        else
          valid = (BigDecimal.new(data.to_s) % BigDecimal.new(current_schema.schema['divisibleBy'].to_s)).to_f == 0
        end
      end
      return valid if !valid
      
      if current_schema.schema['enum']
        valid = current_schema.schema['enum'].include?(data)
      end
      return valid if !valid
      
      
      if current_schema.schema['properties'] && data.is_a?(Hash)
        current_schema.schema['properties'].each do |property,property_schema|
          valid = false if (property_schema['required'] && !data.has_key?(property))
          
          if data.has_key?(property)
            schema = JSON::Schema.new(property_schema,current_schema.uri)
            valid = validate_schema(schema, data[property])
          end
          return valid if !valid
        end
      end
      return valid if !valid
      
      if current_schema.schema['patternProperties'] && data.is_a?(Hash)
        current_schema.schema['properties'].each do |property,property_schema|
          
          r = Regexp.new(property)
          
          # Check each key in the data hash to see if it matches the regex
          data.each do |key,value|
            if r.match(key)
              schema = JSON::Schema.new(property_schema,current_schema.uri)
              valid = validate_schema(schema, data[key])
            end
            return valid if !valid
          end
        end
      end
      return valid if !valid
      
      if current_schema.schema['additionalProperties'] && data.is_a?(Hash)
        extra_properties = data.keys
        
        if current_schema.schema['properties']
          extra_properties = extra_properties - current_schema.schema['properties'].keys
        end
        
        if current_schema.schema['patternProperties']
          current_schema.schema['patternProperties'].each_key do |key|
            r = Regexp.new(key)
            extras_clone = extra_properties.clone
            extras_clone.each do |prop|
              if r.match(prop)
                extra_properties = extra_properties - [prop]
              end
            end
          end
        end
        
        if current_schema.schema['additionalProperties'] == false
          valid = extra_properties.empty?
        elsif current_schema.schema['additionalProperties'].is_a?(Hash)
          data.each do |key,value|
            schema = JSON::Schema.new(current_schema.schema['additionalProperties'],current_schema.uri)
            valid = validate_schema(schema,value)
            return valid if !valid
          end
        end
      end
      return valid if !valid
      
      if current_schema.schema['items'] && data.is_a?(Array)
        if current_schema.schema['items'].is_a?(Hash)
          data.each do |item|
            schema = JSON::Schema.new(current_schema.schema['items'],current_schema.uri)
            valid = validate_schema(schema,item)
            return valid if !valid
          end
        elsif current_schema.schema['items'].is_a?(Array)
          current_schema.schema['items'].each_with_index do |item_schema,i|
            schema = JSON::Schema.new(item_schema,current_schema.uri)
            valid = validate_schema(schema,data[i])
            return valid if !valid
          end
        end
      end
      return valid if !valid
      
      if current_schema.schema['additionalItems'] && data.is_a?(Array) && current_schema.schema['items'].is_a?(array)
        if current_schema.schema['additionalItems'] == false
          return current_schema.schema['additionalItems'].length == data.length
        elsif current_schema.schema['additionaItems'].is_a?(Hash)
          data.each do |item|
            schema = JSON::Schema.new(current_schema.schema['additionalItems'],current_schema.uri)
            valid = validate_schema(schema, item)
            return valid if !valid
          end
        end
      end
      return valid if !valid
      
      if current_schema.schema['dependences'] && data.is_a?(Hash)
        current_schema.schema['dependencies'].each do |property,dependency_value|
          if data.has_key?(property)
            if dependency_value.is_a?(String)
              valid = data.has_key?(dependency_value)
            elsif dependency_value.is_a?(Array)
              dependency_value.each do |value|
                valid = data.has_key?(value)
                break if !valid
              end
            else
              schema = JSON::Schema.new(dependency_value,current_schema.uri)
              valid = validate_schema(schema, data)
            end
            return valid if !valid
          end
        end
      end
      return valid if !valid
      
      # We're referencing another schema
      if current_schema.schema['$ref']
        temp_uri = URI.parse(current_schema.schema['$ref'])
        if temp_uri.relative?
          temp_uri = current_schema.uri.clone
          # Check for absolute path
          path = current_schema.schema['$ref'].split("#")[0]
          if path[0,1] == "/"
            temp_uri.path = Pathname.new(path).cleanpath
          else
            temp_uri.path = (Pathname.new(current_schema.uri.path).parent + path).cleanpath
          end
          temp_uri.fragment = current_schema.schema['$ref'].split("#")[1]
        end
        temp_uri.fragment = "" if temp_uri.fragment.nil?
        
        # Grab the parent schema from the schema list
        schema_key = temp_uri.to_s.split("#")[0]
        ref_schema = @schemas[schema_key]
        
        if ref_schema
          # Perform fragment resolution to retrieve the appropriate level for the schema
          target_schema = ref_schema.schema
          fragments = temp_uri.fragment.split("/")
          fragments.each do |fragment|
            if fragment && fragment != ''
              if target_schema.is_a?(Array)
                target_schema = target_schema[fragment.to_i]
              else
                target_schema = target_schema[fragment]
              end
            end
          end
          
          # We have the schema finally, build it and validate!
          schema = JSON::Schema.new(target_schema,temp_uri)
          valid = validate_schema(schema, data)
        end 
      end
      
      if current_schema.schema['extends']
        schemas = current_schema.schema['extends']
        schemas = [schemas] if !schema.is_a?(Array)
        schemas.each do |s|
          schema = JSON::Schema.new(s,current_schema.uri)
          valid = validate_schema(schema, item)
          return valid if !valid
        end
      end
      
      valid
    end
    
    
    def validate_type(types, data,current_schema)
      union = true
      if !types.is_a?(Array)
        types = [types]
        union = true
      end
      valid = false
      
      types.each do |type|
        if type.is_a?(String)
          case type
          when "string"
            valid = data.is_a?(String)
          when "number"
            valid = data.is_a?(Numeric)
          when "integer"
            valid = data.is_a?(Integer)
          when "boolean"
            valid = (data.is_a?(TrueClass) || data.is_a?(FalseClass))
          when "object"
            valid = data.is_a?(Hash)
          when "array"
            valid = data.is_a?(Array)
          when "null"
            valid = data.is_a?(NilClass)
          else
            valid = true
          end
        elsif type.is_a?(Hash) && union
          # Validate as a schema
          schema = JSON::Schema.new(type,current_schema.uri)
          valid = validate_schema(schema,data)
        end
      
        return valid if valid
      end
      
      valid
    end
    
    def load_ref_schema(parent_schema,ref)
      uri = URI.parse(ref)
      if uri.relative?
        uri = parent_schema.uri.clone
        # Check for absolute path
        path = ref.split("#")[0]
        if path[0,1] == '/'
          uri.path = Pathname.new(path).cleanpath
        else
          uri.path = (Pathname.new(parent_schema.uri.path).parent + path).cleanpath
        end
        uri.fragment = nil
      end
      
      if @schemas[uri.to_s].nil?
        begin
          schema = JSON::Schema.new(JSON.parse(open(uri.to_s).read), uri)
          @schemas[uri.to_s] = schema
          build_schemas(schema)
        rescue
          # Failures will occur when this URI cannot be referenced yet. Don't worry about it,
          # the proper error will fall out if the ref isn't ever defined
        end
      end
    end
    
    
    # Build all schemas with IDs, mapping out the namespace
    def build_schemas(parent_schema)
      if parent_schema.schema["type"] && parent_schema.schema["type"].is_a?(Array) # If we're dealing with a Union type, there might be schemas a-brewin'
        parent_schema.schema["type"].each_with_index do |type,i|
          if type.is_a?(Hash) 
            if type['$ref']
              load_ref_schema(parent_schema, type['$ref'])
            else
              schema_uri = parent_schema.uri.clone
              schema = JSON::Schema.new(type,schema_uri)
              if type['id']
                @schemas[schema.uri.to_s] = schema
              end
              build_schemas(schema)
            end
          end
        end
      end
      
      if parent_schema.schema["disallow"] && parent_schema.schema["disallow"].is_a?(Array) # If we're dealing with a Union type, there might be schemas a-brewin'
        parent_schema.schema["disallow"].each_with_index do |type,i|
          if type.is_a?(Hash)
            if type['$ref']
              load_ref_schema(parent_schema, type['$ref'])
            else
              type['id']
              schema_uri = parent_schema.uri.clone
              schema = JSON::Schema.new(type,schema_uri)
              if type['id']
                @schemas[schema.uri.to_s] = schema
              end
              build_schemas(schema)
            end
          end
        end
      end
        
      if parent_schema.schema["properties"]
        parent_schema.schema["properties"].each do |k,v|
          if v['$ref']
            load_ref_schema(parent_schema, v['$ref'])
          else
            schema_uri = parent_schema.uri.clone
            schema = JSON::Schema.new(v,schema_uri)
            if v['id']
              @schemas[schema.uri.to_s] = schema
            end
            build_schemas(schema)
          end
        end
      end
      
      if parent_schema.schema["additionalProperties"].is_a?(Hash) 
        if parent_schema.schema["additionalProperties"]["$ref"]
          load_ref_schema(parent_schema, parent_schema.schema["additionalProperties"]["$ref"])
        else
          schema_uri = parent_schema.uri.clone
          schema = JSON::Schema.new(parent_schema.schema["additionalProperties"],schema_uri)
          if parent_schema.schema["additionalProperties"]['id']
            @schemas[schema.uri.to_s] = schema
          end
          build_schemas(schema)
        end
      end
      
      if parent_schema.schema["items"]
        items = parent_schema.schema["items"].clone
        single = false
        if !items.is_a?(Array)
          items = [items]
          single = true
        end
        items.each_with_index do |item,i|
          if item['$ref']
            load_ref_schema(parent_schema, item['$ref'])
          else
            schema_uri = parent_schema.uri.clone
            schema = JSON::Schema.new(item,schema_uri)
            if item['id']
              @schemas[schema.uri.to_s] = schema
            end
            build_schemas(schema)
          end
        end
      end
      
      if parent_schema.schema["additionalItems"].is_a?(Hash)
        if parent_schema.schema["additionalItems"]['$ref']
          load_ref_schema(parent_schema, parent_schema.schema["additionalItems"]['$ref'])
        else
          schema_uri = parent_schema.uri.clone
          schema = JSON::Schema.new(parent_schema.schema["additionalItems"],schema_uri)
          if parent_schema.schema["additionalItems"]['id']
            @schemas[schema.uri.to_s] = schema
          end
          build_schemas(schema)
        end
      end
      
      if parent_schema.schema["dependencies"].is_a?(Hash)
        if parent_schema.schema["dependencies"]["$ref"]
          load_ref_schema(parent_schema, parent_schema.schema["dependencies"]['$ref'])
        else
          schema_uri = parent_schema.uri.clone
          schema = JSON::Schema.new(parent_schema.schema["dependencies"],schema_uri)
          if parent_schema.schema["dependencies"]['id']
            @schemas[schema.uri.to_s] = schema
          end
          build_schemas(schema)
        end
      end
    end
        
    
    class << self
      def validate(schema, data)
        validator = JSON::Validator.new(schema, data)
        validator.validate
      end
    end
    
    
    private
    
    def initialize_schema(schema)
      schema_uri = URI.parse("file://#{Dir.pwd}/__base_schema__.json")
      if schema.is_a?(String)
        begin
          schema = JSON.parse(schema)
        rescue
          begin
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
            schema = JSON.parse(open(schema_uri.to_s).read)
          rescue            
            raise "Invalid schema: #{schema_uri.to_s}"
          end
        end
      end
      
      JSON::Schema.new(schema,schema_uri)
    end
    
    
    def initialize_data(data)
      # Parse the data, if any
      if data.is_a?(String)
        begin
          data = JSON.parse(data)
        rescue
          begin
            json_uri = URI.parse(data)
            if json_uri.relative?
              if data[0,1] == '/'
                schema_uri = URI.parse("file://#{data}")
              else
                schema_uri = URI.parse("file://#{Dir.pwd}/#{data}")
              end
            end
            data = JSON.parse(open(json_uri.to_s).read)
          rescue
            raise "Invalid JSON: #{json_uri.to_s}"
          end
        end
      end
      data
    end
    
  end
end