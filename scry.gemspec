# coding: utf-8

require "./lib/scry/version"
require "time"

Gem::Specification.new do |gem|
  gem.name = "scry"
  gem.version = Scry::VERSION
  gem.date = Time.new.strftime("%Y-%m-%d")
  gem.authors = "Atomic Jolt"

  gem.summary = "Downloads Blackboard Cartridges"
  gem.description = "Commandline tool that downloads blackboard cartridges"
  gem.homepage = "https://github.com/atomicjolt/scry"
  gem.email = "joel@atomicjolt.com"
  gem.license = "MIT"
  gem.extra_rdoc_files = ["README.md"]

  gem.files = Dir["LICENSE.txt", "README.md", "lib/**/*", "bin/*"]
  gem.executables = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }

  gem.add_development_dependency "pry-byebug", "~> 3.4"
  gem.add_development_dependency "rspec", "~> 3.5"

  gem.metadata["allowed_push_host"] = "https://github.com/atomicjolt/"

  [
    ["rake", "~> 11.3"],
    ["mechanize", "~> 2.7", ">= 2.7.5"],
    ["fileutils", "~> 0.7"],
    ["sidekiq", "~> 4.2"],
    ["thin", "~> 1.7"],
  ].each { |d| gem.add_runtime_dependency(*d) }
end
