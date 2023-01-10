source 'https://rubygems.org'

gemspec

group :release do
  gem 'github_changelog_generator', require: false
end

group :coverage, optional: ENV['COVERAGE']!='yes' do
  gem 'simplecov-console', :require => false
  gem 'simplecov-lcov' , :require => false
end

group :local_coverage, optional: ENV['LOCAL_COVERAGE']!='yes' do
  gem 'simplecov-console', :require => false
  gem 'simplecov' , :require => false
  gem 'simplecov-lcov' , :require => false
end

group :tests do
  gem 'rubocop', '~> 1.11.0'
  gem 'rubocop-rspec', '~> 2.2.0'
  gem 'rubocop-rake', '~> 0.5.1'
  gem 'rubocop-performance', '~> 1.10.2'
end
