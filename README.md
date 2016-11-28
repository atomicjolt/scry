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

Create a ruby file `workers.rb` and add
```ruby
require "scry/workers"
```

Create a `Rakefile` and add
```ruby
require "scry/tasks"
Scry::Tasks.install_tasks
```

Create a `sidekiq.yml` file and add
```yml
:concurrency: 5
:queues:
  - scry_export_generator
  - scry_export_downloader

```

## Usage

Start up sidekiq
```sh
bundle exec sidekiq -r ./workers.rb -C sidekiq.yml
```

Run the rake task to download all the courses.
It takes the url that the courses are located at, login, password, and optionally the directory they should go into.
```sh
bundle exec rake scry:scrape[https://blackboard.com/,login,password]
```
This will download each cartridge zip into the default directory `blackboard_exports`

To specify the directory:
```sh
bundle exec rake scry:scrape[https://blackboard.com/,login,password,other_dir]
```

Delete entire blackboard_exports folder
```sh
bundle exec rake scry:clean
```

Monitor sidekiq
```sh
bundle exec monitor
```

# Development

After checking out the repo, run `bundle install` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Running sidekiq

Need redis running first: `redis-server`

Run `bundle exec sidekiq -r ./lib/scry/workers.rb -C sidekiq.yml`

To get access to the workers in code require "lib/scry/sidekiq/boot.rb"

To monitor sidekiq using the web UI, run `bin/monitor`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/scry. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
