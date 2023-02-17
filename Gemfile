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

group :tests do
  gem 'rubocop', '~> 1.45.0'
  gem 'rubocop-rspec', '~> 2.18.1'
  gem 'rubocop-rake', '~> 0.6.0'
  gem 'rubocop-performance', '~> 1.16.0'
end
