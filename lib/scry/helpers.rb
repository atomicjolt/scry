require "scry/sidekiq/workers/log_writer"

module Scry
  module Helpers
    ##
    # Clicks a link with the given text.
    ##
    def click_link(agent:, page:, text:)
      agent.click(page.link_with(text: text))
    end

    ##
    # Enqueues data to be written to a log file.
    ##
    def write_log(log, data)
      Scry::LogWriter.perform_async(log, data)
    end
  end
end
