require "rake/clean"
require "scry"

DEFAULT_DIR = "blackboard_exports".freeze

module Scry
  class Tasks
    extend Rake::DSL if defined? Rake::DSL

    def self.install_tasks
      namespace :scry do
        desc "Scrape the given url for course data"
        task :scrape, [:url, :login, :passwd, :dir] do |_t, args|
          args.with_defaults(dir: DEFAULT_DIR)
          url = args.url
          login = args.login
          passwd = args.passwd
          dir = args.dir
          mkdir_p dir
          Scry.scrape(url, login, passwd, dir)
        end

        task :clean do
          rm_rf DEFAULT_DIR
        end
      end
    end
  end
end