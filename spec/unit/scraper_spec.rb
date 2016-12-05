require "scry"
require "rspec"
require "scry/sidekiq/workers/export_generator"
require "helpers/spec_helper"

RSpec.configure do |config|
  config.before(:each) do
    stub_toe(:get, /home.html/, "home_page.html")
    stub_toe(
      :post,
      /login/,
      "index_page.html",
      body: { user_id: "bob", password: "12345" },
    )
    stub_toe(:get, /course_list/, "course_list.html")
  end
end

describe Scry do
  describe "scrape" do
    before do
      allow(Scry).to receive(:url).and_return("http://blackboard.com/home.html")
      allow(Scry).to receive(:login).and_return("bob")
      allow(Scry).to receive(:passwd).and_return("12345")
      allow(Scry).to receive(:courses_downloaded).and_return("")
    end

    it "should queue export jobs" do
      expect do
        Scry.scrape
      end.to change(Scry::ExportGenerator.jobs, :size).by(2)

      expect(Scry::ExportGenerator.jobs[0]["args"][1]).to eq(
        "http://blackboard.com/home.html/launcher?type=Course&id=_63344_1&url=",
      )
      expect(Scry::ExportGenerator.jobs[1]["args"][1]).to eq(
        "http://blackboard.com/home.html/launcher?type=Course&id=_62733_1&url=",
      )
    end
  end
end
