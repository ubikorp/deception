# == Schema Information
#
# Table name: players
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  game_id    :integer
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  setup do
    Factory(:werewolf)
  end

  should_belong_to :user
  should_belong_to :game

  should_validate_presence_of :user_id, :game_id
  should_validate_uniqueness_of :user_id, :scoped_to => :game_id

  context 'dead players' do
    setup do
      @game   = Factory(:game)
      @player = Factory(:villager, :game => @game)
    end

    should 'be dead if they were killed' do
      @event = Factory(:kill_event, :game => @game, :target_player => @player)
      assert @player.dead?
    end

    should 'be dead if they committed suicide' do
      @event = Factory(:quit_event, :game => @game, :source_player => @player)
      assert @player.dead?
    end
  end
end
