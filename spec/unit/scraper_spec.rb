require "scry"
require "rspec"

include Scry

describe Scry do
  describe "#scrape" do
    it "returns the directory" do
      expect(Scry.scrape("blackboard")).to eq("blackboard")
    end
  end
end
