spec = Gem::Specification.new do |s|
  s.name = "json-schema"
  s.version = "0.1.0"
  s.authors = ["Kenny Hoxworth"]
  s.email = "hoxworth@gmail.com"
  s.homepage = "http://github.com/hoxworth/json-schema/tree/master"
  s.summary = "Ruby JSON Schema Validator"
  s.files = ["lib/json-schema.rb",
             "lib/json-schema/schema.rb",
             "lib/json-schema/validator.rb",
             "lib/json-schema/uri/file.rb"]
  s.require_path = "lib"
  s.test_files = ["test/test_jsonschema.rb"]
  s.has_rdoc = true
  s.add_dependency('json')
  s.description = "A Ruby JSON Schema Validator based on JSON Schema draft 03"
  s.extra_rdoc_files = ["README.textile"]
end