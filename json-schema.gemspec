require 'yaml'

version_yaml = YAML.load(File.open(File.expand_path('../VERSION.yml', __FILE__)).read)
version = "#{version_yaml['major']}.#{version_yaml['minor']}.#{version_yaml['patch']}"
gem_name = "json-schema"

Gem::Specification.new do |s|
  s.name = gem_name
  s.version = version
  s.authors = ["Kenny Hoxworth"]
  s.email = "hoxworth@gmail.com"
  s.homepage = "http://github.com/ruby-json-schema/json-schema/tree/master"
  s.summary = "Ruby JSON Schema Validator"
  s.files = Dir[ "lib/**/*", "resources/*.json" ]
  s.require_path = "lib"
  s.extra_rdoc_files = ["README.md","LICENSE.md"]
  s.required_ruby_version = ">= 1.9"
  s.license = "MIT"
  s.required_rubygems_version = ">= 1.8"

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest", '~> 5.0'
  s.add_development_dependency "webmock"
  s.add_development_dependency "bundler"

  s.add_runtime_dependency "addressable", '>= 2.4'
end
