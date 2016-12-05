require "mechanize"
require "scry"
require "scry/helpers"
require "scry/export_failed"

TWO_HOURS = 7200

module Scry
  ##
  # This class represents a course for which we are extracting data
  ##
  class Course
    include Scry::Helpers

    ##
    # A new course accepts a Mechanize Agent
    # and a Mechanize::Page::Link object for a course link
    ##
    def initialize(agent, course_link)
      @agent = agent
      @course_link = course_link
    end

    ##
    # Creates a new instance of a course
    # from given cookies so the user is signed in
    ##
    def self.from_cookies(cookie_crumbs, course_url)
      agent = Mechanize.new
      agent.cookie_jar = YAML::load(cookie_crumbs)
      course_link = Mechanize::Page::Link.new(
        {
          "href" => course_url,
        },
        agent,
        nil,
      )
      Course.new(agent, course_link)
    end

    ##
    # Creates an export file for the course
    #
    # Navigates from the course page to the export course page
    # and creates an export for the course.
    #
    # First it all existing exports, then attempts to create a new export.
    #
    # It will wait indefinitely for the export to be created.
    ##
    def create_export
      course_page = @agent.click(@course_link)
      package_links = course_page.links_with(
        text: /Packages & Utilities Overview Page/,
      )
      if package_links.any?
        utilities_page = click_link(
          agent: @agent,
          page: course_page,
          text: /Packages & Utilities Overview Page/,
        )
        exports_page = click_link(
          agent: @agent,
          page: utilities_page,
          text: /Export\/Archive Course/,
        )
        export_button_link = exports_page.links_with(
          text: /Export Package/,
        )
        if export_button_link.any?
          course_id =
            exports_page.form_with(name: "selectFileToDelete")["courseId"]
          _delete_existing_exports(exports_page, course_id, nil)
          export_page = click_link(
            agent: @agent,
            page: exports_page,
            text: /Export Package/,
          )
          exports_page = _process_export_form(export_page)
          exports = exports_page.links_with(
            text: "View Basic Log",
          )
          _wait_for_export(exports, utilities_page, exports_page, course_id)
        else
          write_log(
            Scry.export_generation_no_export_button,
            @course_link.href.strip,
          )
        end
      end
    end

    ##
    # Opens the log for an export and checks if it was successful.
    ##
    def validate_export(exports_page)
      links = exports_page.links_with(text: "View Basic Log")
      if links.empty?
        raise Scry::ExportFailed, "Links empty #{exports_page.uri}"
      end
      url = links.last.attributes["onclick"][/'(.*)'/, 1]
      log_page = @agent.get(url)
      text = Nokogiri::HTML(log_page.body).css("div#containerdiv").text
      !text.match(/error/i)
    end

    ##
    # Extracts the download URL for an export
    ##
    def download_url(page)
      download_link = page.links_with(text: "Open").last
      download_link.href
    end

    ##
    # Downloads the export into the given directory.
    ##
    def download_export(url)
      puts "Start downloading #{url}"
      time = Time.now
      @agent.pluggable_parser["application/zip"] = Mechanize::Download
      filename = File.basename(URI.parse(url).path)
      @agent.get(url).save(File.join(Scry.default_dir, filename))
      elapsed = Time.now - time
      puts "Done downloading #{url} took #{elapsed} seconds"
    end

    ##
    # :nodoc:
    # Fills out the export form and submits it.
    ##
    def _process_export_form(export_page)
      export_page.form_with(name: "selectCourse") do |export_form|
        export_form.radiobutton_with(
          id: "copyLinkToCourseFilesAndCopiesOfContent",
        ).check
        export_form.radiobutton_with(
          id: "copyLinkToExternalCourseFilesAndCopiesOfContent",
        ).check
        export_form.checkboxes.each(&:check)
      end.submit
    end

    ##
    # :nodoc:
    # Waits indefinitely for an export to show up on the exports page.
    ##
    def _wait_for_export(exports, utilities_page, exports_page, course_id)
      time = Time.now
      elapsed = 0
      puts "Begin waiting for export link for #{course_id}"
      while exports.count.zero? && elapsed < TWO_HOURS
        sleep 30
        exports_page = click_link(
          agent: @agent,
          page: utilities_page,
          text: /Export\/Archive Course/,
        )
        exports = exports_page.links_with(
          text: "View Basic Log",
        )
        elapsed = Time.now - time
        puts "#{course_id} waited #{elapsed.to_i} seconds for link"
      end
      if elapsed >= TWO_HOURS
        raise Scry::ExportFailed, "Export timeout for #{course_id}"
      end
      puts "#{course_id} done after #{(Time.now - time).to_i} seconds"
      exports_page
    end

    ##
    # :nodoc:
    # Deletes all existing exports from a page.
    ##
    def _delete_existing_exports(page, course_id, links)
      links ||= page.links_with(text: "Delete")
      puts "#{course_id} Deleting exports... #{links.count} remaining"
      if links.any?
        filename = links.last.href[/'(.*)'\,/, 1]

        page = page.form_with(name: "selectFileToDelete") do |form|
          form.field_with(name: "filename").value = filename
        end.submit

        links = page.links_with(text: "Delete")
        if links.any?
          _delete_existing_exports(page, course_id, links)
        end
      end
    end
  end
end
