Feature: Joining Games
In order to participate in a game
As a user
I want to be able to join an existing game

  Scenario: User joins an open game
    Given I am signed in
    And there is a pending game called "The Incident at Mariahville"
    When I go to the game page for "The Incident at Mariahville"
    And I press "Join Game"
    Then I should see "Thanks for joining"

  Scenario: User joins an invite-only game
    Given I am signed in
    And there is an invite-only game called "The Incident at Mariahville"
    And I have an invite for "The Incident at Mariahville"
    When I go to the game page for "The Incident at Mariahville"
    And I press "Join Game"
    Then I should see "Thanks for joining"

  Scenario: User without an invitation cannot join an invite-only game
    Given I am signed in
    And there is an invite-only game called "The Incident at Mariahville"
    When I go to the game page for "The Incident at Mariahville"
    Then I should not see "Join Game"
