# Scry

## Runing sidekiq

`bundle exec sidekiq -r ./lib/scry/sidekiq/boot.rb -C lib/scry/sidekiq/sidekiq.yml`

To get access to the workers require "lib/scry/sidekiq/boot.rb"

To monitor sidekiq using the web UI, run `bin/monitor`
