Gem::Specification.new do |s|
  s.name = 'json-schema'
  s.version = '5.0.0'
  s.authors = ['Kenny Hoxworth', 'Vox Pupuli']
  s.email = 'voxpupuli@groups.io'
  s.homepage = 'https://github.com/voxpupuli/json-schema/'
  s.metadata = {
    'source_code_uri' => s.homepage,
    'changelog_uri' => "#{s.homepage}/blob/master/CHANGELOG.md",
    'bug_tracker_uri' => "#{s.homepage}/issues",
  }
  s.summary = 'Ruby JSON Schema Validator'
  s.files = Dir['lib/**/*', 'resources/*.json']
  s.require_path = 'lib'
  s.extra_rdoc_files = ['README.md', 'LICENSE.md']
  s.required_ruby_version = '>= 2.7'
  s.license = 'MIT'

  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'voxpupuli-rubocop', '~> 2.8.0'
  s.add_development_dependency 'webmock', '~> 3.23'

  s.add_runtime_dependency 'addressable', '~> 2.8'
end
