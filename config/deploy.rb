set :application, "deception"
set :repository,  "set your repository location here"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "wolf.zerosum.org"
role :web, "wolf.zerosum.org"
role :db,  "wolf.zerosum.org", :primary => true

after "deploy:symlink", "deploy:update_crontab"

# for whenever / scheduling
namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end
