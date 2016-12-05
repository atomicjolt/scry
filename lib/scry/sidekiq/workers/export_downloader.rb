require "mechanize"
require "sidekiq"
require "scry"
require "scry/course"
require "scry/export_failed"
require "scry/helpers"

module Scry
  ##
  # Works on downloading an export.
  #
  # Will attempt 5 times before giving up.
  ##
  class ExportDownloader
    include Sidekiq::Worker
    include Scry::Helpers
    sidekiq_options queue: :scry_export_downloader, retry: 5

    ##
    # Instigates downloading an export.
    #
    # Creates a course from the cookies,
    # then starts downloading the export.
    ##
    def perform(cookie_crumbs, course_url, download_url)
      course = Course.from_cookies(cookie_crumbs, course_url)
      uri = URI.parse(course_url)
      uri.path = download_url
      course.download_export(uri.to_s)
      write_log(Scry.export_download_good, course_url)
    rescue SocketError, Mechanize::Error, Net::HTTPClientError => e
      write_log(
        Scry.export_download_bad,
        "#{course_url} #{e.class} #{e.message}",
      )
      raise
    end
  end
end
