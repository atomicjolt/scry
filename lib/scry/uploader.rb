require "rubygems"
require "mechanize"
require "pandarus"
require "scry"
require "scry/sidekiq/workers/export_uploader"
require "scry/helpers"
require "scry/course"

module Scry
  extend Scry::Helpers

  ##
  # Creates sidekiq jobs for each course to generate an export.
  #
  # Logs in the user and goes over every course
  # and creates a sidekiq to generate an export for it.
  ##
  def self.upload
    files_downloaded = Dir.glob(File.join(Scry.default_dir, "*.zip"))
    courses_uploaded = Scry.courses_uploaded

    Scry.courses_downloaded.each_line do |course_downloaded|
      course_code = course_id_from_log(course_downloaded)
      course_name = course_name_from_log(course_downloaded)

      course_file_path = files_downloaded.find do |file_path|
        file_path.include?(course_code)
      end

      if course_file_path && !courses_uploaded.include?(course_file_path)
        ExportUploader.perform_async(course_name, course_code, course_file_path)
      else
        raise "Export in #{Scry.export_download_good} not found in #{Scry.default_dir}!"
      end
    end
  end
end
