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
    #
    # course_id is the text id that blackboard has for the course, NOT the id
    # given in the url.
    ##
    def perform(cookie_crumbs, course_url, course_id, course_name)
      course = Course.from_cookies(cookie_crumbs, course_url)
      exports_page = course.create_export
      if exports_page.is_a? Mechanize::Page
        valid = course.validate_export(exports_page)
        if valid
          write_log(Scry.export_generation_good, course_url)
          download_url = course.download_url(exports_page)
          Scry::ExportDownloader.perform_async(
            cookie_crumbs,
            course_url,
            download_url,
            course_id,
            course_name
          )
        else
          write_log(Scry.export_generation_bad, course_url)
          raise Scry::ExportFailed, "Something failed"
        end
      end
    end
  end
end
