require 'yaml'

version_yaml = YAML.load(File.open('VERSION.yml').read)
version = "#{version_yaml['major']}.#{version_yaml['minor']}.#{version_yaml['patch']}"
gem_name = "json-schema"

Gem::Specification.new do |s|
  s.name = gem_name
  s.version = version
  s.authors = ["Kenny Hoxworth"]
  s.email = "hoxworth@gmail.com"
  s.homepage = "http://github.com/hoxworth/json-schema/tree/master"
  s.summary = "Ruby JSON Schema Validator"
  s.files = Dir[ "lib/**/*", "resources/*.json" ]
  s.require_path = "lib"
  s.test_files = Dir[ "test/**/test*", "test/{data,schemas}/*.json" ]
  s.extra_rdoc_files = ["README.textile","LICENSE.md"]
  s.required_ruby_version = ">= 1.8.7"
  s.license = "MIT"
  s.required_rubygems_version = ">= 1.8"

  s.add_development_dependency "webmock"
end
