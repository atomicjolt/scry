require "scry/scraper"

EXPORT_GENERATION_GOOD = "export_generation_good.txt".freeze
EXPORT_GENERATION_BAD = "export_generation_bad.txt".freeze
EXPORT_DOWNLOAD_GOOD = "export_download_good.txt".freeze
EXPORT_DOWNLOAD_BAD = "export_download_bad.txt".freeze
EXPORT_GENERATION_NO_EXPORT_BUTTON =
  "export_generation_no_export_button.txt".freeze

DEFAULT_DIR = "blackboard_exports".freeze

module Scry
  def self.config
    if File.exists? "scry.yml"
      YAML::load(File.read("scry.yml"))
    else
      {}
    end
  end

  def self.url
    Scry.config[:url]
  end

  def self.login
    Scry.config[:login]
  end

  def self.passwd
    Scry.config[:passwd]
  end

  def self.default_dir
    Scry.config[:default_dir] || DEFAULT_DIR
  end

  def self.export_generation_good
    Scry.config[:export_generation_good] || EXPORT_GENERATION_GOOD
  end

  def self.export_generation_bad
    Scry.config[:export_generation_bad] || EXPORT_GENERATION_BAD
  end

  def self.export_download_good
    Scry.config[:export_download_good] || EXPORT_DOWNLOAD_GOOD
  end

  def self.export_download_bad
    Scry.config[:export_download_bad] || EXPORT_DOWNLOAD_BAD
  end

  def self.export_generation_no_export_button
    Scry.config[:export_generation_no_export_button] ||
      EXPORT_GENERATION_NO_EXPORT_BUTTON
  end
end
