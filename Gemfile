source 'https://rubygems.org'

gemspec

gem 'minitest', '>= 5.0', '< 7'
gem 'minitest_reporters_github', '~> 1.0', '>= 1.0.1'
gem 'rake', '~> 13.0'
gem 'voxpupuli-rubocop', '~> 5.1.0' if RUBY_VERSION >= '3.2'
gem 'webmock', '~> 3.23'

group :release, optional: true do
  gem 'faraday-retry', '~> 2.1', require: false
  gem 'github_changelog_generator', '~> 1.16.4', require: false
end
