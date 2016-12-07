require "sidekiq"
require "rest-client"
require "pandarus"
require "scry"
require "scry/course"
require "scry/export_failed"
require "scry/helpers"
require 'byebug'
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
    # Instigates generating an export.
    #
    # Creates a course from the cookies,
    # then starts generating the export.
    #
    # course_id is the text id that blackboard has for the course, NOT the id
    # given in the url.
    ##
    def perform(course_name, course_code, export_path)
      canvas = Pandarus::Client.new(
        prefix: Scry.canvas_api_url,
        token: Scry.canvas_auth_token,
        account_id: Scry.canvas_account_id,
      )

      course = canvas.create_new_course(
        {
          "course__name__" => course_name,
          "course__course_code__" => course_code,
        }
      )

      content_migration = canvas.create_content_migration_courses(
        course.id,
        "blackboard_importer",
        {
          "pre_attachment__name__" => File.basename(export_path)
        }
      )

      cm_pre_attachment = content_migration.pre_attachment
      content_migration_upload_params = cm_pre_attachment["upload_params"]
      content_migration_upload_url = cm_pre_attachment["upload_url"]
      content_migration_upload_params["file"] = File.new(export_path)
      begin
        response = RestClient.post(
          content_migration_upload_url,
          content_migration_upload_params
        )
      rescue => e
        byebug
        c = 1
      end

      content_migration = canvas.get_content_migration_courses(
        course.id,
        content_migration.id
      )

      byebug
      c = 1

    end
  end
end
