require "rubygems"
require "mechanize"
require "scry/sidekiq/workers/export_generator"
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
  def self.scrape
    url = Scry.url
    login = Scry.login
    passwd = Scry.passwd

    agent = Mechanize.new do |secret_agent_man|
      secret_agent_man.follow_meta_refresh = true
    end

    agent.get(url) do |home_page|
      index_page = home_page.form_with(name: "login") do |form|
        form["user_id"] = login
        form["password"] = passwd
      end.submit
      courses_page = click_link(
        agent: agent,
        page: index_page,
        text: /Open Bb Course List/,
      )

      courses_done = if File.exists?(Scry.export_download_good)
                       File.read(Scry.export_download_good)
                     end

      # It is currently unknown if the links on the courses_page are paginated
      # This gets them as if they are not.
      course_links = courses_page.links_with(href: /type=Course/)
      course_links.each do |course_link|
        course_url = course_link.href.strip
        if courses_done && !courses_done.include?(course_url)
          cookie_crumbs = agent.cookie_jar.to_yaml
          Scry::ExportGenerator.perform_async(
            cookie_crumbs,
            File.join(url, course_url),
          )
        end
      end
    end
  end
end
