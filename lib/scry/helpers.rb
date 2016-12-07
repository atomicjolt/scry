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

    ##
    # Returns the blackboard course name from the link text
    ##
    def bb_course_name(link_text)
      link_text.strip.split(":", 2).last
    end

    ##
    # Returns the blackboard text course id from the link text if present, else
    # returns nil
    ##
    def bb_course_id(link_text)
      split_text = link_text.strip.split(":", 2)
      split_text.count > 1 ? split_text.first : nil
    end

    ##
    # Returns the course name from the good download log line
    ##
    def course_name_from_log(log_line)
      log_line.strip.split(" ", 3).last
    end

    ##
    # Returns the course id from the good download log line
    ##
    def course_id_from_log(log_line)
      split_line = log_line.strip.split(" ", 3)
      split_line.count < 3 ? nil : split_line[2]
    end

    def courses_downloaded
      if File.exists?(Scry.export_download_good)
        File.read(Scry.export_download_good)
      else
        ""
      end
    end
  end
end
