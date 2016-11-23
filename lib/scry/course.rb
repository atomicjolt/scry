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

    def create_export
      course_page = @agent.click(@course_link)
      package_links = course_page.links_with(
        text: /Packages & Utilities Overview Page/,
      )
      if package_links.any?
        course_page_expanded = click_link(
          agent: @agent,
          page: course_page,
          text: /Packages & Utilities Overview Page/,
        )
        utilities_page = click_link(
          agent: @agent,
          page: course_page_expanded,
          text: /Export\/Archive Course/,
        )
        export_links = utilities_page.links_with(
          text: /Export Package/,
        )
        if export_links.any?
          _delete_existing_exports(utilities_page, nil)
          export_page = click_link(
            agent: @agent,
            page: utilities_page,
            text: /Export Package/,
          )
          utilities_page = _process_export_form(export_page)
          exports = utilities_page.links_with(
            text: "View Basic Log",
          )
          _wait_for_export(exports, course_page_expanded)
        end
      end
    end

    def validate_export(utilities_page)
      links = utilities_page.links_with(text: "View Basic Log")
      if links.empty?
        raise Scry::ExportFailed, "Links empty #{utilities_page.uri}"
      end
      url = links.last.attributes["onclick"][/'(.*)'/, 1]
      log_page = @agent.get(url)
      text = Nokogiri::HTML(log_page.body).css("div#containerdiv").text
      !text.match(/error/i)
    end

    def download_url(page)
      download_link = page.links_with(text: "Open").last
      download_link.href
    end

    def download_export(url, dir)
      @agent.pluggable_parser["application/zip"] = Mechanize::Download
      filename = File.basename(URI.parse(url).path)
      @agent.get(url).save(File.join(dir, filename))
    end

    def _process_export_form(export_page)
      export_page.form_with(name: "selectCourse") do |export_form|
        export_form.radiobuttons[1].check
        export_form.radiobuttons[3].check
        export_form.checkboxes.each(&:check)
      end.submit
    end

    def _wait_for_export(exports, course_page)
      while exports.count.zero?
        utilities_page = click_link(
          agent: @agent,
          page: course_page,
          text: /Export\/Archive Course/,
        )
        exports = utilities_page.links_with(
          text: "View Basic Log",
        )
        puts "waiting for link"
        sleep 30
      end
      utilities_page
    end

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
