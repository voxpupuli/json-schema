Gem::Specification.new do |s|
  s.name = 'json-schema'
  s.version = '6.1.0'
  s.authors = ['Kenny Hoxworth', 'Vox Pupuli']
  s.email = 'voxpupuli@groups.io'
  s.homepage = 'https://github.com/voxpupuli/json-schema/'
  s.metadata = {
    'source_code_uri' => s.homepage,
    'changelog_uri' => "#{s.homepage}/blob/master/CHANGELOG.md",
    'bug_tracker_uri' => "#{s.homepage}/issues",
    'funding_uri' => 'https://github.com/sponsors/voxpupuli',
  }
  s.summary = 'Ruby JSON Schema Validator'
  s.files = Dir['lib/**/*', 'resources/*.json']
  s.require_path = 'lib'
  s.extra_rdoc_files = ['README.md', 'LICENSE.md']
  s.required_ruby_version = '>= 2.7'
  s.license = 'MIT'

  s.add_dependency 'addressable', '~> 2.8'
  s.add_dependency 'bigdecimal', '>= 3.1', '< 5'
end
