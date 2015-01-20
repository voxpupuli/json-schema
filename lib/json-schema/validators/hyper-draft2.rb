module JSON
  class Schema

    class HyperDraft2 < Draft2
      def initialize
        super
        @uri = Addressable::URI.parse("http://json-schema.org/draft-02/hyper-schema#")
      end

      JSON::Validator.register_validator(self.new)
      JSON::Validator.register_default_validator(self.new)
    end
  end
end
