require 'yaml'

version_yaml = YAML.load(File.open(File.expand_path('../VERSION.yml', __FILE__)).read)
version = "#{version_yaml['major']}.#{version_yaml['minor']}.#{version_yaml['patch']}"
gem_name = 'json-schema'

Gem::Specification.new do |s|
  s.name = gem_name
  s.version = version
  s.authors = ['Kenny Hoxworth', 'Vox Pupuli']
  s.email = 'voxpupuli@groups.io'
  s.homepage = 'http://github.com/voxpupuli/json-schema/'
  s.summary = 'Ruby JSON Schema Validator'
  s.files = Dir['lib/**/*', 'resources/*.json']
  s.require_path = 'lib'
  s.extra_rdoc_files = ['README.md', 'LICENSE.md']
  s.required_ruby_version = '>= 2.5'
  s.license = 'MIT'
  s.required_rubygems_version = '>= 2.5'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'webmock'

  s.add_runtime_dependency 'addressable', '>= 2.8'
end
