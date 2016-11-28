require "bundler/setup"
require "rspec"
require "scry/tasks"

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

task default: :spec

Scry::Tasks.install_tasks
