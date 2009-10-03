namespace :game do
  namespace :periods do
    desc "Continue selected games, move to next period"
    task :update => :environment do
      Game.update_periods
    end
  end
end
