module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the homepage/
      '/'

    when /the new game page/
      new_game_path

    when /the game page for "(.*?)"/
      game_path(Game.find_by_name($1))

    when /the pending games page/
      pending_games_path

    when /the ongoing games page/
      games_path

    when /the finished games page/
      finished_games_path

    when /the new invitations page for "(.*?)"/
      new_game_invitation_path(Game.find_by_name($1))
    
    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
