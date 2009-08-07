# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:

set :cron_log, "/var/www/apps/werewolf/shared/log/cron_log.log"

# should be the same as the min_period_length in settings.yml
every 10.minutes do
  rake "game:messages:receive"
  rake "game:periods:update"
  rake "game:messages:send"
end

every 3.minutes do
  rake "game:messages:receive"
  rake "game:messages:send"
end

# every 4.days do
#   command "/usr/bin/some_great_command"
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
