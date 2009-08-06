Feature: Playing Games through the Web Interface
In order to participate in a game
As a user
I want to be able to make vote and quit actions on the web
And receive game progress messages

  Background:
    Given I am a user named "zapnap"

  Scenario: User should see list of active players
    Given there is a game called "The Incident at Mariahville"
    And "aaronstack" is a "player" in the game
    And "ebloodstone" is a "player" in the game
    And the game has started
    When I go to the game page for "The Incident at Mariahville"
    Then I should see "Cast & Crew"
    And I should see "aaronstack"

  Scenario: Current user votes to lynch a player
    Given I am signed in
    And there is a game called "The Incident at Mariahville"
    And "aaronstack" is a "player" in the game
    And I am a "player" in the game
    And the game is in its "2nd" period
    When I go to the game page for "The Incident at Mariahville"
    And I select "aaronstack" from "victims"
    And I press "Submit Choice"
    Then I should see "DAY PHASE"
    And I should see "Yeah, that one sure looks suspicious to me"
    And the vote for "aaronstack" has been recorded

  Scenario: Current user changes his vote
    Given I am signed in
    And there is a game called "The Incident at Mariahville"
    And "aaronstack" is a "player" in the game
    And "ebloodstone" is a "player" in the game
    And I am a "player" in the game
    And the game is in its "2nd" period
    And I have voted to kill "aaronstack"
    When I go to the game page for "The Incident at Mariahville"
    And I select "ebloodstone" from "victims"
    And I press "Submit Choice"
    Then I should see "Yeah, that one sure looks suspicious to me"
    And the vote for "ebloodstone" has been recorded
    And there is no vote for "aaronstack"

  Scenario: Current user quits the current game
    Given I am signed in
    And there is a game called "The Incident at Mariahville"
    And I am a "player" in the game
    When I go to the game page for "The Incident at Mariahville"
    And I press "Leave Game"
    Then I should see "Your player has committed suicide and left this game"
    And I should no longer be playing in a game

  Scenario: User should view history of ongoing game
    Given there is a game called "The Incident at Mariahville"
    And "aaronstack" is a "villager" in the game
    And the game is in its "1st" period
    And a werewolf killed "aaronstack" in the game
    When I go to the game page for "The Incident at Mariahville"
    Then I should see "The Story So Far"
    And I should see "aaronstack was killed"

  Scenario: Werewolf user votes to kill a player
    Given I am signed in
    And there is a game called "The Incident at Mariahville"
    And I am a "werewolf" in the game
    And "aaronstack" is a "villager" in the game
    And the game is in its "1st" period
    When I go to the game page for "The Incident at Mariahville"
    And I select "aaronstack" from "victims"
    And I press "Submit Choice"
    Then I should see "NIGHT PHASE"
    And I should see "Aye, he looks like a tasty one"
    And the vote for "aaronstack" has been recorded

  Scenario: User sees working screen while game period turnover happens
    Given there is a game called "The Incident at Mariahville"
    And the game is in its "2nd" period
    And there is no time left in the current period
    When I go to the game page for "The Incident at Mariahville"
    Then I should see "Please Wait"
