require "rubygems"
require "mechanize"
require "sidekiq"

module Scry
  class HardWorker
    include Sidekiq::Worker
    sidekiq_options queue: "scry_default"

    def perform
      puts "Hello world"
    end
  end
end
