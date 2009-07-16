require File.dirname(__FILE__) + '/../spec_helper'

describe 'Game script' do
  before(:each) do
    @nick  = Factory(:nick)
    @jeff  = Factory(:jeff)
    @darcy = Factory(:darcy)
    @aaron = Factory(:aaron)
    @elsa  = Factory(:elsa)

    @game  = Factory(:game, :owner => @darcy)

    @nick.join(@game, :werewolf)
    @jeff.join(@game, :villager)
    @darcy.join(@game, :villager)
    @aaron.join(@game, :villager)
    @elsa.join(@game, :villager)

    @game.start
  end

  it 'should be won by werewolf' do
    # 1. night: werewolf kills villager one
    @nick.vote(@jeff)
    @game.continue
    @jeff.active_player.should == nil

    # 2. day: villagers vote to lynch villager two
    @nick.vote(@darcy)
    @darcy.vote(@nick)
    @aaron.vote(@darcy)
    @elsa.vote(@aaron)
    @game.continue
    @darcy.active_player.should == nil

    # 3. night: werewolf kills villager three
    @nick.vote(@aaron)
    @game.continue
    @aaron.active_player.should == nil

    # 4. day: stalemated voting, nobody gets lynched
    lambda {
      @nick.vote(@elsa)
      @elsa.vote(@nick)
      @game.continue
    }.should_not change(KillEvent, :count)

    # 5. night: werewolf kills villager four, wins
    @nick.vote(@elsa)
    @game.continue
    @elsa.active_player.should == nil
    
    @game.finished?.should == true
    @game.winner.should include(@nick.players.last)

    # game is finished, no players are active
    @nick.active_player.should == nil
  end

  it 'should be won by villagers' do
    # 1. night: werewolf kills villager four
    @nick.vote(@elsa)
    @game.continue
    @elsa.active_player.should == nil

    # 2. day: villagers vote to lynch werewolf
    @nick.vote(@aaron)
    @jeff.vote(@nick)
    @darcy.vote(@nick)
    @aaron.vote(@darcy)
    @game.continue
    @nick.active_player.should == nil

    @game.finished?.should == true
    @game.winner.should include(@jeff.players.last)
  end
end
