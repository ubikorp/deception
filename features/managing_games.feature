Feature: Managing Games
In order to manage games
As a user
I want to be able to create games
And edit games that I have created

  Scenario: Anonymous user cannot create a game
    When I go to the new game page
    Then I should be redirected to login

  Scenario: Registered user creates a game
    Given I am signed in
    When I go to the new game page
    And I fill in "Name" with "The Incident at Devonshire"
    And I select "Open Game" from "Game Type"
    And I select "30 minutes" from "Period Length"
    And I press "Create Game"
    Then I should see "Your game has been created"

  Scenario: Registered user tries to run two games simultaneously
    Given I am signed in
    And I am already participating in a game
    When I go to the new game page
    Then I should see "Sorry, you cannot participate in more than one game at a time"

  Scenario: User invites friends to an open game
    Given I am signed in
    And there is a game called "The Incident at Mariahville"
    When I go to the game page for "The Incident at Mariahville"
    Then I can invite my friends

  Scenario: User invites friends to a private game
    Given I am signed in
    When I go to "the game page"
    Then I can invite my friends

  Scenario: User aborts game
    Given I am signed in
    And I am the creator of this game
    When I go to "the game page"
    Then I can abort the game

  Scenario: User manually starts game
    Given I am signed in
    And I am the creator of this game
    And the game has at least the minimum number of players
    When I go to "the game page"
    Then I can start the game

  Scenario: User fails to manually start game
    Given I am signed in
    And I am the creator of this game
    And the game has less than the minimum number of players
    When I go to "the game page"
    Then I cannot start the game
