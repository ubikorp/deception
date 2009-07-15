Feature: Viewing Games
In order to view games
and find games I might want to participate in
As a user
I want to be able to see lists of ongoing and finished games

  Scenario: User views a list of finished games
    Given that there is a finished game called "Finished Game"
    When I go to the finished games page
    Then I should see "Finished Game"

  Scenario: User views a list of ongoing games
    Given that there is an ongoing game called "Game In Progress"
    When I go to the ongoing games page
    Then I should see "Game In Progress"
    
  Scenario: User views a list of games looking for players
    Given that there is a pending game called "Pending Game"
    When I go to the pending games page
    Then I should see "Pending Game"
