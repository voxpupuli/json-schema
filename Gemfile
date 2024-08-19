source 'https://rubygems.org'

gemspec

group :release do
  gem 'faraday-retry', require: false
  gem 'github_changelog_generator', require: false
end

group :coverage, optional: ENV['COVERAGE'] != 'yes' do
  gem 'codecov', require: false
  gem 'simplecov-console', require: false
end
