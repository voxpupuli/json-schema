Gem::Specification.new do |s|
  s.name = 'json-schema'
  s.version = '4.3.1'
  s.authors = ['Kenny Hoxworth', 'Vox Pupuli']
  s.email = 'voxpupuli@groups.io'
  s.homepage = 'https://github.com/voxpupuli/json-schema/'
  s.metadata = {
    'source_code_uri' => s.homepage,
    'changelog_uri' => "#{s.homepage}/blob/master/CHANGELOG.md",
    'homepage_uri' => s.homepage,
    'bug_tracker_uri' => "#{s.homepage}/issues",
  }
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
