require "sidekiq"

##
# Writes log files
#
# Will attempt 5 times before giving up.
##
module Scry
  class LogWriter
    include Sidekiq::Worker
    sidekiq_options queue: :scry_log_writer, retry: 5

    ##
    # Writes data to the given log file
    ##
    def perform(log, data)
      File.open(log, "a") do |file|
        file.puts data
      end
    end
  end
end
