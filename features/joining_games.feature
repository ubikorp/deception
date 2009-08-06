Feature: Joining Games
In order to participate in a game
As a user
I want to be able to join an existing game

  Background:
    Given I am a user named "zapnap"

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
    And I should see "is a private game"

  Scenario: Anonymous visitor should be invited to login to check game invitation status
    Given there is an invite-only game called "The Incident at Mariahville"
    When I go to the game page for "The Incident at Mariahville"
    Then I should not see "Join Game"
    And I should see "is a private game"
    And I should see "Sign in with Twitter"

  Scenario: Anonymous visitor should be invited to login to join an open game
    Given there is a pending game called "The Incident at Mariahville"
    When I go to the game page for "The Incident at Mariahville"
    Then I should not see "Join Game"
    And I should see "Sign in with Twitter"

  Scenario: Anonymous user logs in to join an open game
    Given there is a pending game called "The Incident at Mariahville"
    When I go to the game page for "The Incident at Mariahville"
    And I follow "Sign in with Twitter"
    And Twitter authorizes me
    Then I should see "Logged in as"
    And I should be redirected to the game page for "The Incident at Mariahville"

  Scenario: User cannot join game because it is no longer in setup phase
    Given I am signed in
    And there is an ongoing game called "The Incident at Mariahville"
    When I go to the game page for "The Incident at Mariahville"
    Then I should not see "Join Game"
    And I should see "The Story So Far..."

  Scenario: User cannot join game because he is already a participant
    Given I am signed in
    And there is a pending game called "The Incident at Mariahville"
    And I am a "player" in the game
    When I go to the game page for "The Incident at Mariahville"
    Then I should not see "Join Game"
    And I should see "You're scheduled to play in this game"

  Scenario: Game auto-starts when final player joins
    Given I am signed in
    And there is a pending game called "The Incident at Mariahville"
    And the game needs one more player to auto-start
    When I go to the game page for "The Incident at Mariahville"
    And I press "Join Game"
    Then I should see "Please Wait"
    Then the game is waiting to start

  Scenario: User should be reminded to follow the gamebot when they join a game
    Given I am signed in
    And there is a pending game called "The Incident at Mariahville"
    And I am a "player" in the game
    When I go to the game page for "The Incident at Mariahville"
    And I press "Follow us on Twitter"
    Then I should be redirected to the game page for "The Incident at Mariahville"
    And I should see "following @"
    And I should not see "Play on Twitter"
    And I should be following the gamebot user on Twitter
