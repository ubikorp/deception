namespace :game do
  namespace :messages do
    desc "Sending pending messages via Twitter"
    task :send => :environment do
      OutgoingMessage.send_messages
    end

    desc "Receive player status updates from Twitter"
    task :receive => :environment do
      IncomingMessage.receive_messages
    end
  end

  namespace :periods do
    desc "Continue selected games, move to next period"
    task :update => :environment do
      Game.update_periods
    end
  end
end
