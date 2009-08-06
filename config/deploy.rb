default_run_options[:pty] = true
set :application, "werewolf"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/apps/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

set :repository,  "git@github.com:ubikorp/deception.git"
set :scm, :git
set :deploy_via, :remote_cache
set :branch, "master"
set :user, 'deploy'

role :app, "werewolfgame.net"
role :web, "werewolfgame.net"
role :db,  "werewolfgame.net", :primary => true

after "deploy:symlink", "deploy:update_crontab"

# for whenever / scheduling
namespace :deploy do
  desc "Restarting passenger with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with passenger"
    task t, :roles => :app do ; end
  end

  task :after_update_code, :roles => :app do
    run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -s #{shared_path}/config/settings.yml #{release_path}/config/settings.yml"
    run "ln -s #{shared_path}/system #{release_path}/public/system"
  end

  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end

namespace :monitor do
  desc "Monitor the production log"
  task :production_log, :roles => :app do
    run "tail -n 150 -f #{shared_path}/log/production.log" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}" 
      break if stream == :err    
    end
  end
  
  desc "remotely console" 
  task :console, :roles => :app do
    input = ''
    run "#{current_path}/script/console production" do |channel, stream, data|
      next if data.chomp == input.chomp || data.chomp == ''
      print data
      channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
    end
  end
  
  desc "shows running processes and free memory" 
  task :resources, :roles => :app do
    input = ''
    run "ps aux && free && uptime" do |channel, stream, data|
      next if data.chomp == input.chomp || data.chomp == ''
      print data
      channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
    end
  end
end
