module Scry
  module Helpers
    ##
    # Clicks a link with the given text.
    ##
    def click_link(agent:, page:, text:)
      agent.click(page.link_with(text: text))
    end

    ##
    # Writes data to a given log file.
    ##
    def write_log(log, data)
      File.open(log, "a") do |file|
        file.puts data
      end
    end
  end
end
