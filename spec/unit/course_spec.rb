require "scry"
require "rspec"
require "helpers/spec_helper"
require "byebug"

RSpec.configure do |config|
  config.before(:each) do
    stub_course_pages
    stub_utilities_page
    stub_exports_page
    stub_exports_page_with_exports
    stub_export_page
    stub_valid_log_page
  end
end

COOKIE_CRUMBS = %{
--- !ruby/object:Mechanize::CookieJar
store: !ruby/object:HTTP::CookieJar::HashStore
  mon_owner:
  mon_count: 0
  mon_mutex: !ruby/object:Thread::Mutex {}
  logger:
  gc_threshold: 150
  jar:
    blackboard.com:
      \"/\": {}
  gc_index: 0
}.freeze

INSTRUCTOR_COURSE_URL =
  "http://blackboard.com/launcher?id=_62733_1&type=Course&url=".freeze
STUDENT_COURSE_URL =
  "http://blackboard.com/launcher?id=_63344_1&type=Course&url=".freeze

describe Scry::Course do
  describe "from_cookies" do
    it "should return a new course" do
      course = Scry::Course.from_cookies(COOKIE_CRUMBS, INSTRUCTOR_COURSE_URL)
      expect(course).to be_a(Scry::Course)
    end
  end
end

describe Scry::Course do
  context "instructor course" do
    before do
      @course = Scry::Course.from_cookies(COOKIE_CRUMBS, INSTRUCTOR_COURSE_URL)
      allow(@course).to receive(:_delete_existing_exports).and_return(true)
      @exports_page = @course.create_export
    end

    describe "create_export" do
      it "should create an export" do
        expect(@exports_page).to be_a(Mechanize::Page)
      end
    end

    describe "validate_export" do
      it "should validate" do
        valid = @course.validate_export(@exports_page)
        expect(valid).to eq true
      end

      it "should invalidate" do
        stub_invalid_log_page
        valid = @course.validate_export(@exports_page)
        expect(valid).to eq false
      end
    end
  end
end

describe Scry::Course do
  context "student course" do
    before do
      @course = Scry::Course.from_cookies(COOKIE_CRUMBS, STUDENT_COURSE_URL)
    end

    describe "create_export" do
      it "should not create an export" do
        expect do
          @course.create_export
        end.to change(Scry::ExportGenerator.jobs, :size).by(0)
      end
    end
  end
end
