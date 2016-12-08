require "rest-client"
require "pandarus"

module Scry
  class CanvasCourse
    def initialize(name, code, export_path)
      @name = name
      @code = code
      @export_path = export_path

      @canvas = Pandarus::Client.new(
        prefix: Scry.canvas_api_url,
        token: Scry.canvas_auth_token,
        account_id: Scry.canvas_account_id,
      )

      @canvas_course = nil
    end

    def canvas_id
      @canvas_course && @canvas_course.id
    end

    def create_on_canvas
      @canvas_course = @canvas.create_new_course(
        "course__name__" => @name,
        "course__course_code__" => @code,
      )
    end

    ##
    # Uploads to canvas then waits for the import to finish
    #
    # Returns whether the canvas import succeeded
    ##
    def import_into_canvas
      content_migration = @canvas.create_content_migration_courses(
        @canvas_course.id,
        "blackboard_importer",
        "pre_attachment__name__" => File.basename(@export_path),
      )

      cm_pre_attachment = content_migration.pre_attachment
      content_migration_upload_params = cm_pre_attachment["upload_params"]
      content_migration_upload_url = cm_pre_attachment["upload_url"]
      content_migration_upload_params["file"] = File.new(@export_path)

      begin
        RestClient.post(
          content_migration_upload_url,
          content_migration_upload_params,
        )
      rescue RestClient::Found => e
        # If successful canvas responds with a redirect that we must post to.
        # For some reason RestClient raises that as an exception, so we have to
        # rescue the redirect to finish the upload.

        RestClient.post(
          e.http_headers[:location],
          nil,
          "Authorization" => "Bearer #{Scry.canvas_auth_token}",
        )
      end

      wait_for_import_finish(content_migration)
    end

    ##
    # Waits for the content migration to finish the import into canvas
    #
    # Returns whether the canvas import succeeded
    ##
    def wait_for_import_finish(content_migration)
      content_migration = @canvas.get_content_migration_courses(
        @canvas_course.id,
        content_migration.id,
      )

      progress_id = URI(content_migration.progress_url).path.split("/").last

      progress = @canvas.query_progress(progress_id)

      while progress.completion < 100 && progress.workflow_state != "failed"
        sleep 5
        progress = @canvas.query_progress(progress_id)
      end

      progress.workflow_state != "failed"
    end
  end
end
