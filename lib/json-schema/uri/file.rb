require 'uri'

module URI

  # Ruby does not have built-in support for filesystem URIs, and definitely does not have built-in support for
  # using open-uri with filesystem URIs
  class File < Generic
    
    COMPONENT = [
          :scheme,  
          :path, 
          :fragment,
          :host
        ].freeze
        
    def initialize(*arg)
      arg[2] = ""
      super(*arg)
    end
    
    def self.build(args)
      tmp = Util::make_components_hash(self, args)
      return super(tmp)
    end
    
    def open(*rest, &block)
      ::File.open(self.path, *rest, &block)
    end
    
    @@schemes['FILE'] = File
  end
end