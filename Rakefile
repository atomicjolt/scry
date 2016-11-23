require "bundler/setup"
require "rspec"
require "rake/clean"

DEFAULT_DIR = "blackboard_exports".freeze

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

task default: :spec

task :scrape, [:url, :login, :passwd, :dir] do |_t, args|
  args.with_defaults(dir: DEFAULT_DIR)
  url = args.url
  login = args.login
  passwd = args.passwd
  dir = args.dir
  mkdir_p dir
  sh "ruby -Ilib ./bin/scrape_blackboard #{url} #{login} #{passwd} #{dir}/"
end

task :clean do
  rm_rf DEFAULT_DIR
end
