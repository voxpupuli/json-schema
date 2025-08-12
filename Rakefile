require 'rake'
require 'rake/testtask'

desc 'Updates the json-schema common test suite to the latest version'
task :update_common_tests do
  unless File.read('.git/config').include?('submodule "test/test-suite"')
    sh 'git submodule init'
  end

  puts 'Updating json-schema common test suite...'

  begin
    sh 'git submodule update --remote --quiet'
  rescue StandardError
    warn 'Failed to update common test suite.'
  end
end

desc 'Update meta-schemas to the latest version'
task :update_meta_schemas do
  puts 'Updating meta-schemas...'

  require 'open-uri'
  require 'thwait'

  download_threads = Dir['resources/*.json'].map do |path|
    schema_uri = File.read(path)[/"\$?id"\s*:\s*"(.*?)"/, 1]

    Thread.new(schema_uri) do |uri|
      Thread.current[:uri] = uri

      begin
        metaschema = URI(uri).read

        File.write(path, metaschema)
      rescue StandardError
        false
      end
    end
  end

  ThreadsWait.all_waits(*download_threads) do |t|
    if t.value
      puts t[:uri]
    else
      warn "Failed to update meta-schema #{t[:uri]}"
    end
  end
end

Rake::TestTask.new do |t|
  t.libs << '.'
  t.warning = true
  t.verbose = true
  t.test_files = FileList.new('test/*_test.rb')
end

task update: %i[update_common_tests update_meta_schemas]

begin
  require 'voxpupuli/rubocop/rake'
rescue LoadError
  # the voxpupuli-rubocop gem is optional
end

task default: :test

begin
  require 'rubygems'
  require 'github_changelog_generator/task'
rescue LoadError
else
  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.exclude_labels = %w[duplicate question invalid wontfix wont-fix skip-changelog dependencies]
    config.user = 'voxpupuli'
    config.project = 'json-schema'
    gem_version = Gem::Specification.load("#{config.project}.gemspec").version
    config.future_release = "v#{gem_version}"
  end
end
