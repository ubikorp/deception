namespace :game do
  namespace :messages do
    desc "Sending pending messages via Twitter"
    task :send => :environment do
      OutgoingMessage.send_messages
    end
  end

  namespace :periods do
    desc "Continue selected games, move to next period"
    task :update => :environment do
      Game.update_periods
    end
  end
end
