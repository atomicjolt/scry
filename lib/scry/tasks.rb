require "rake/clean"
require "scry"

module Scry
  class Tasks
    extend Rake::DSL if defined? Rake::DSL

    ##
    # Creates rake tasks that can be ran from the gem.
    #
    # Add this to your Rakefile
    #
    #   require "scry/tasks"
    #   Scry::Tasks.install_tasks
    #
    ##
    def self.install_tasks
      namespace :scry do
        desc "Scrape the configured url for course data"
        task :scrape do
          mkdir_p Scry.default_dir
          Scry.scrape
        end

        desc "Completely delete all downloaded files"
        task :clean do
          rm_rf Scry.default_dir
        end

        desc "Upload scraped courses to canvas"
        task :upload do
          Scry.upload
        end
      end
    end
  end
end
