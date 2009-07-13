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
#  dead       :boolean
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Player do
  before(:each) do
    @game     = Factory(:game)
    @werewolf = Factory(:werewolf, :game => @game)
    @villager = Factory(:villager, :game => @game)
    @game.start
  end

  it { should belong_to(:user) }
  it { should belong_to(:game) }

  it { should have_scope(:alive,      :conditions => { :dead => false }) }
  it { should have_scope(:villagers,  :conditions => { :type => 'Villager' }) }
  it { should have_scope(:werewolves, :conditions => { :type => 'Werewolf' }) }

  it { should validate_presence_of(:user_id, :game_id) }
  it { should validate_uniqueness_of(:user_id, :scope => :game_id) }

  it 'should have to be added to a game during the setup phase' do
    @game = Factory(:game)
    Factory(:darcy).join(@game)
    Factory(:aaron).join(@game)
    Factory(:elsa).join(@game)
    @game.start
    @player = Factory.build(:player, :game => @game)
    @player.should_not be_valid
    @player.errors.on(:game_id).should include("is already in progress")
  end

  it 'should be a werewolf' do
    @werewolf.should be_werewolf
    @werewolf.should_not be_villager
  end

  it 'should be a villager' do
    @villager.should be_villager
    @villager.should_not be_werewolf
  end

  context 'dead players' do
    it 'should be dead if they were killed' do
      @event = Factory(:kill_event, :period => @game.current_period, :target_player => @villager)
      @villager.should be_dead
    end

    it 'should be dead if they committed suicide' do
      @event = Factory(:quit_event, :period => @game.current_period, :source_player => @villager)
      @villager.should be_dead
    end
  end
end
