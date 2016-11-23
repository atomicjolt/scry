module Scry
  module Helpers
    def click_link(agent:, page:, text:)
      agent.click(page.link_with(text: text))
    end

    def write_log(log, data)
      File.open(log, "a") do |file|
        file.puts data
      end
    end
  end
end
