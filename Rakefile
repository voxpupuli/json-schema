require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/gempackagetask'
require 'yaml'

version_yaml = YAML.load(File.open('VERSION.yml').read)
version = "#{version_yaml['major']}.#{version_yaml['minor']}.#{version_yaml['patch']}"
puts version
gem_name = "json-schema"

spec = Gem::Specification.new do |s|
  s.name = gem_name
  s.version = version
  s.authors = ["Kenny Hoxworth"]
  s.email = "hoxworth@gmail.com"
  s.homepage = "http://github.com/hoxworth/json-schema/tree/master"
  s.summary = "Ruby JSON Schema Validator"
  s.files = FileList["{lib}/**/*"].to_a
  s.require_path = "lib"
  s.test_files = FileList["{test}/**/test*"].to_a
  s.has_rdoc = true
  s.add_dependency('json')
  s.extra_rdoc_files = ["README.textile"]
end

Rake::TestTask.new do |t|
  t.libs << "."
  t.test_files = FileList['test/test*.rb']
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
