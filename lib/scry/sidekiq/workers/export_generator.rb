require "sidekiq"
require "scry"
require "scry/course"
require "scry/export_failed"
require "scry/helpers"
require "scry/sidekiq/workers/export_downloader"

##
# Works on generating the export.
#
# Will attempt 5 times before giving up.
##
module Scry
  class ExportGenerator
    include Sidekiq::Worker
    include Scry::Helpers
    sidekiq_options queue: :scry_export_generator, retry: 5

    ##
    # Instigates generating an export.
    #
    # Creates a course from the cookies,
    # then starts generating the export.
    ##
    def perform(cookie_crumbs, course_url)
      course = Course.from_cookies(cookie_crumbs, course_url)
      exports_page = course.create_export
      if exports_page
        valid = course.validate_export(exports_page)
        if valid
          write_log(Scry.export_generation_good, course_url)
          download_url = course.download_url(exports_page)
          Scry::ExportDownloader.perform_async(
            cookie_crumbs,
            course_url,
            download_url,
          )
        else
          write_log(Scry.export_generation_bad, course_url)
          raise Scry::ExportFailed, "Something failed"
        end
      end
    end
  end
end
