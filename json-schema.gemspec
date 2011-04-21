require 'yaml'

version_yaml = YAML.load(File.open('VERSION.yml').read)
version = "#{version_yaml['major']}.#{version_yaml['minor']}.#{version_yaml['patch']}"
gem_name = "json-schema"

spec = Gem::Specification.new do |s|
  s.name = gem_name
  s.version = version
  s.authors = ["Kenny Hoxworth"]
  s.email = "hoxworth@gmail.com"
  s.homepage = "http://github.com/hoxworth/json-schema/tree/master"
  s.summary = "Ruby JSON Schema Validator"
  s.files = Dir.glob("{lib}/**/*")
  s.require_path = "lib"
  s.test_files = Dir.glob("{test}/**/test*")
  s.extra_rdoc_files = ["README.textile"]
end
