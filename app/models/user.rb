# == Schema Information
#
# Table name: users
#
#  id                           :integer         not null, primary key
#  twitter_id                   :string(255)
#  login                        :string(255)
#  access_token                 :string(255)
#  access_secret                :string(255)
#  remember_token               :string(255)
#  remember_token_expires_at    :datetime
#  name                         :string(255)
#  location                     :string(255)
#  description                  :string(255)
#  profile_image_url            :string(255)
#  url                          :string(255)
#  protected                    :boolean
#  profile_background_color     :string(255)
#  profile_sidebar_fill_color   :string(255)
#  profile_link_color           :string(255)
#  profile_sidebar_border_color :string(255)
#  profile_text_color           :string(255)
#  profile_background_image_url :string(255)
#  profile_background_tiled     :boolean
#  friends_count                :integer
#  statuses_count               :integer
#  followers_count              :integer
#  favourites_count             :integer
#  utc_offset                   :integer
#  time_zone                    :string(255)
#  created_at                   :datetime
#  updated_at                   :datetime
#  following                    :boolean
#  notify_start                 :boolean         default(TRUE)
#  notify_finish                :boolean         default(TRUE)
#  notify_period_change         :boolean         default(TRUE)
#  notify_death                 :boolean         default(TRUE)
#  notify_quit                  :boolean         default(TRUE)
#  notify_reply                 :boolean         default(TRUE)
#

class User < TwitterAuth::GenericUser
  # Extend and define your user model as you see fit.
  # All of the authentication logic is handled by the 
  # parent TwitterAuth::GenericUser class.

  has_many :players
  has_many :games, :through => :players

  has_many :managed_games, :class_name => 'Game', :foreign_key => :owner_id

  # return the game player for the game that this user is actively participating in
  # or nil if they are not currently active in a game
  def active_player
    player = nil
    players(true).each do |p|
      player = p unless p.dead? or p.game.finished?
    end

    player
  end

  # determine whether or not this user has an invite to a particular game
  # if the game has selected open invitations, this will always return true
  def has_invite?(game)
    if !game.invite_only?
      true
    else
      game.invitations.select { |i| i.twitter_login == login }.length > 0
    end
  end

  # join a new game (during the game setup phase)
  # a user can only participate in one game at a time
  # only once they have been removed / killed in their active game may they join a new game
  #
  # join supports an optional second argument, which allows us to 'hint' at the role we
  # would like the user to have in the game.
  def join(game, role = nil)
    if !active_player && has_invite?(game)
      player = players.build(:game => game)
      if player.save
        role.nil? ? player : player.assign_role(role)
      else
        false
      end
    else
      # TODO: may want to raise here?
      false
    end
  end

  # record a vote in the user's current game
  def vote(user)
    if player = active_player
      pvote = VoteEvent.new(:period => player.game.current_period, :source_player => player, :target_player => user.active_player)
      if pvote.save
        pvote
      else
        false
      end
    else
      # TODO: may want to raise here?
      false
    end
  end

  # leave an in-progress game
  def quit(game = nil)
    if player = active_player
      if player.game.setup?
        player.destroy # hasn't started yet, leave without saying goodbye
      else
        # game is in-progress; issue a proper QuitEvent (suicide) to leave
        pquit = QuitEvent.new(:period => player.game.current_period, :source_player => player)
        if pquit.save
          pquit
        else
          false
        end
      end
    else
      # TODO: may want to raise here?
      false
    end
  end

  # discover which user we voted for in the given period
  def voted_in(period)
    victim = false

    if player = active_player
      if target = player.voted_in_period(period)
        victim = target.user
      end
    end

    victim
  end

  # check whether or not the user is following the gamebot user on Twitter
  # use following?(true) to do a live query (otherwise returned cached data)
  def following?(force_check = false)
    if force_check
      res = twitter.get("/friendships/show?target_screen_name=#{TwitterAuth.config['gamebot_user']}")
      res = JSON.parse(res) if res.is_a?(String)
      status = res['relationship']['source']['following']
      update_attribute(:following, status) && status
    else
      read_attribute(:following)
    end
  end

  # update user to auto-follow the gamebot on Twitter
  def follow_game
    unless following?(true)
      twitter.post("/friendships/create/#{TwitterAuth.config['gamebot_user']}.json?follow=true")
      update_attribute(:following, true)
    end

    true
  end
end
