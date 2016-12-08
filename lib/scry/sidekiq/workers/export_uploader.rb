require "sidekiq"
require "scry"
require "scry/canvas_course"
require "scry/helpers"

##
# Works on uploading the export.
#
# Will attempt 5 times before giving up.
##
module Scry
  class ExportUploader
    include Sidekiq::Worker
    include Scry::Helpers
    sidekiq_options queue: :scry_export_uploader, retry: 5

    ##
    # Uploads an export to canvas
    #
    # Creates a canvas course from the course name and code,
    # then creates a content migration and uploads the export to the blackboard
    # importer
    ##
    def perform(course_name, course_code, export_path)
      course = CanvasCourse.new(course_name, course_code, export_path)

      course.create_on_canvas

      success = course.import_into_canvas

      if success
        write_log(
          Scry.export_upload_good,
          "#{export_path} course: #{course && course.canvas_id}",
        )
      else
        write_log(
          Scry.export_upload_bad,
          "#{export_path} course: #{course && course.canvas_id}",
        )
      end
    rescue
      write_log(
        Scry.export_upload_bad,
        "#{export_path} course: #{course && course.canvas_id}",
      )
    end
  end
end
