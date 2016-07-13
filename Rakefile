require 'bundler'
require 'rake'
require 'rake/testtask'

Bundler::GemHelper.install_tasks

desc "Updates the json-schema common test suite to the latest version"
task :update_common_tests do
  unless File.read(".git/config").include?('submodule "test/test-suite"')
    sh "git submodule init"
  end
  sh "git submodule update --remote --quiet"
end

Rake::TestTask.new do |t|
  t.libs << "."
  t.warning = true
  t.verbose = true
  t.test_files = FileList.new('test/*_test.rb')
end

task :test => :update_common_tests

task :default => :test
