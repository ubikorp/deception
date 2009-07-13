require 'test_helper'

class GamesTest < ActionController::IntegrationTest
  context 'a visitor' do
    should "be able to list games that are currently in-progress" do
      create_game(:playable)

      visit games_url
      assert_contain @game.name
    end

    should "be able to list games that need players" do
      create_game(:setup)

      visit available_games_url
      assert_contain @game.name
    end

    should "be able to list finished games" do
      create_game(:finished)

      visit finished_games_url
      assert_contain @game.name
    end
  end

  context 'a registered user' do
    should "be able to create a new game" do
      flunk
      visit new_game_url
      fill_in "name", :with => "My New Game"
      click_button "Create"
      assert_contain "Created New Game"
    end
  end

  def create_game(state = :setup)
    @game  = Factory(:game, :invite_only => false)
    @nick  = Factory(:nick)
    @jeff  = Factory(:jeff)
    @darcy = Factory(:darcy)
    @aaron = Factory(:aaron)
    @elsa  = Factory(:elsa)

    @nick.join(@game, :werewolf)
    @jeff.join(@game)
    @darcy.join(@game)
    @aaron.join(@game)
    @elsa.join(@game)

    @game.start if [:playable, :finished].include?(state)
    @game.finish if state == :finished
  end
end
