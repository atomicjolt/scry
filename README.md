# Scry

# Scry [![Build Status](https://travis-ci.org/atomicjolt/scry.svg?branch=master)](https://travis-ci.org/atomicjolt/scry)

TODO: Describe the gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem "scry"
```

And then execute:
```sh
$ bundle
```

Or install it yourself as:
```sh
$ gem install scry
```

## Usage

Run the rake task to download all the courses
```sh
rake scrape
```
This will download each cartridge zip into the default directory `blackboard_exports`

To specify the directory:
```sh
rake scrape other_dir
```

Delete entire blackboard_exports folder
```sh
rake clean
```

Monitor sidekiq
```sh
bin/monitor
```

## Development

After checking out the repo, run `bundle install` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Running sidekiq

Run `bundle exec sidekiq -r ./lib/scry/sidekiq/boot.rb -C lib/scry/sidekiq/sidekiq.yml`

To get access to the workers in code require "lib/scry/sidekiq/boot.rb"

To monitor sidekiq using the web UI, run `bin/monitor`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/scry. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
