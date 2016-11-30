require "mechanize"
require "scry/helpers"
require "scry/export_failed"

module Scry
  class Course
    include Scry::Helpers

    ##
    # This class represents a course for which we are extracting data
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
        export_links = exports_page.links_with(
          text: /Export Package/,
        )
        if export_links.any?
          _delete_existing_exports(exports_page, nil)
          export_page = click_link(
            agent: @agent,
            page: exports_page,
            text: /Export Package/,
          )
          exports_page = _process_export_form(export_page)
          exports = exports_page.links_with(
            text: "View Basic Log",
          )
          _wait_for_export(exports, utilities_page, exports_page)
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
    def download_export(url, dir)
      @agent.pluggable_parser["application/zip"] = Mechanize::Download
      filename = File.basename(URI.parse(url).path)
      @agent.get(url).save(File.join(dir, filename))
    end

    ##
    # :nodoc:
    # Fills out the export form and submits it.
    ##
    def _process_export_form(export_page)
      export_page.form_with(name: "selectCourse") do |export_form|
        export_form.radiobuttons[1].check
        export_form.radiobuttons[3].check
        export_form.checkboxes.each(&:check)
      end.submit
    end

    ##
    # :nodoc:
    # Waits indefinitely for an export to show up on the exports page.
    ##
    def _wait_for_export(exports, utilities_page, exports_page)
      while exports.count.zero?
        exports_page = click_link(
          agent: @agent,
          page: utilities_page,
          text: /Export\/Archive Course/,
        )
        exports = exports_page.links_with(
          text: "View Basic Log",
        )
        puts "waiting for link"
        sleep 30
      end
      exports_page
    end

    ##
    # :nodoc:
    # Deletes all existing exports from a page.
    ##
    def _delete_existing_exports(page, links)
      links ||= page.links_with(text: "Delete")
      puts "Deleting... #{links.count} remaining"
      if links.any?
        filename = links.last.href[/'(.*)'\,/, 1]

        page = page.form_with(name: "selectFileToDelete") do |form|
          form.field_with(name: "filename").value = filename
        end.submit

        links = page.links_with(text: "Delete")
        if links.any?
          _delete_existing_exports(page, links)
        end
      end
    end
  end
end
