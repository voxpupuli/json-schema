require 'rubygems'
require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "."
  t.test_files = FileList['test/test*.rb']
end

task :default => :test
