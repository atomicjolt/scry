require "sidekiq"
require "scry/course"
require "scry/export_failed"
require "scry/helpers"
require "scry/sidekiq/workers/export_downloader"

module Scry
  class ExportGenerator
    include Sidekiq::Worker
    include Scry::Helpers
    sidekiq_options queue: :scry_export_generator, retry: 5

    def perform(cookie_crumbs, course_url, dir)
      course = Course.from_cookies(cookie_crumbs, course_url)
      exports_page = course.create_export
      if exports_page
        valid = course.validate_export(exports_page)
        if valid
          write_log("export_generation_good.txt", course_url)
          download_url = course.download_url(exports_page)
          Scry::ExportDownloader.perform_async(
            cookie_crumbs,
            course_url,
            download_url,
            dir,
          )
        else
          write_log("export_generation_bad.txt", course_url)
          raise Scry::ExportFailed, "Something failed"
        end
      end
    end
  end
end
