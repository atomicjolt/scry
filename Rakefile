require "bundler/setup"
require "rspec"
require "rake/clean"

OUTPUT_DIRECTORY = "blackboard_exports".freeze

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

task default: :spec

task :scrape, [:output_directory] do |_t, args|
  args.with_defaults(output_directory: OUTPUT_DIRECTORY)
  output_directory = args.output_directory
  mkdir_p output_directory
  sh "ruby -Ilib ./bin/scrape_blackboard #{OUTPUT_DIRECTORY}/"
end

task :clean do
  rm_rf OUTPUT_DIRECTORY
end
