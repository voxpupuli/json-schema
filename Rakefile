require 'rubygems'
require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  unless File.read(".git/config").include?('submodule "test/test-suite"')
    sh "git submodule init"
  end
  sh "git submodule update"
  t.libs << "."
  t.test_files = FileList['test/test*.rb']
end

task :default => :test
