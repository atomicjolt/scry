require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

require "sidekiq/testing"

def fixture_reader(name)
  File.read(File.join(File.dirname(__FILE__), "../fixtures/", name))
end

def stub_toe(type, pattern, page, with_params = nil)
  request = stub_request(type, pattern).
    to_return(
      status: 200,
      body: fixture_reader(page),
      headers: { content_type: "text/html" },
    )
  if with_params
    request.with(with_params)
  end
end

def stub_course_pages
  stub_toe(:get, /id=_62733_1\&type=Course/, "course_page_instructor.html")
  stub_toe(:get, /id=_63344_1\&type=Course/, "course_page_student.html")
end

def stub_utilities_page
  stub_toe(
    :get,
    /course_id=_62733_1\&filterForCourse=true/,
    "utilities_page.html",
  )
end

def stub_exports_page
  stub_toe(
    :get,
    /archive_manager.jsp\?contextNavItem=control_panel\&course_id=_62733_1/,
    "exports_page.html",
  )
end

def stub_exports_page_with_exports
  stub_toe(
    :post,
    /contentExchange\?course_id=_62733_1/,
    "exports_page_with_exports.html",
  )
end

def stub_export_page
  stub_toe(
    :get,
    /contentExchange\?contextNavItem=control_panel\&course_id=_62733_1/,
    "export_page.html",
  )
end

def stub_valid_log_page
  stub_toe(:get, /readLog.jsp\?course_id=_62733_1/, "log_page_valid.html")
end

def stub_invalid_log_page
  stub_toe(:get, /readLog.jsp\?course_id=_62733_1/, "log_page_invalid.html")
end
