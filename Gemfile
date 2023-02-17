source 'https://rubygems.org'

gemspec

group :release do
  gem 'github_changelog_generator', :require => false
end

group :coverage, :optional => ENV['COVERAGE']!='yes' do
  gem 'codecov', :require => false
  gem 'simplecov-console', :require => false
end

group :tests do
  gem 'rubocop', '~> 1.12.0' # newer version require Ruby 2.6
  gem 'rubocop-minitest', '~> 0.19.0' # newer version requires Ruby 2.6
  gem 'rubocop-performance', '~> 1.13.0' # newer version requires Ruby 2.6
  gem 'rubocop-rake', '~> 0.6.0' # latest
  gem 'rubocop-rspec', '~> 2.4.0' # newer version require Ruby 2.6 or rubocop 1.19
end
