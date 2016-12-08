require "scry"
require "rspec"
require "scry/sidekiq/workers/export_uploader"
require "helpers/spec_helper"

# RSpec.configure do |config|
#   config.before(:each) do
#     stub_toe(:get, /home.html/, "home_page.html")
#     stub_toe(
#       :post,
#       /login/,
#       "index_page.html",
#       body: { user_id: "bob", password: "12345" },
#     )
#     stub_toe(:get, /course_list/, "course_list.html")
#   end
# end

describe Scry do
  describe "upload" do
    before do
      allow(Scry).to receive(:url).and_return("http://blackboard.com/home.html")
      allow(Scry).to receive(:login).and_return("bob")
      allow(Scry).to receive(:passwd).and_return("12345")
    end

    it "queues upload jobs" do
      pending
    end

    it "does not queue upload jobs if they are already successfully uploaded" do
      pending
    end
  end
end
