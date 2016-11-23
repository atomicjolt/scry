#!/usr/bin/env ruby

Dir["./lib/scry/sidekiq/workers/*.rb"].each { |file| require file }
