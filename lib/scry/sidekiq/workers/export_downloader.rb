require "mechanize"
require "sidekiq"
require "scry/course"
require "scry/export_failed"
require "scry/helpers"

module Scry
  class ExportDownloader
    include Sidekiq::Worker
    include Scry::Helpers
    sidekiq_options queue: :scry_export_downloader, retry: 5

    def perform(cookie_crumbs, course_url, download_url, dir)
      course = Course.from_cookies(cookie_crumbs, course_url)
      uri = URI.parse(course_url)
      uri.path = download_url
      course.download_export(uri.to_s, dir)
      write_log("export_download_good.txt", course_url)
    rescue SocketError, Mechanize::Error, Net::HTTPClientError => e
      write_log(
        "export_download_bad.txt",
        "#{course_url} #{e.class} #{e.message}",
      )
      raise
    end
  end
end
