Feature: Managing Games
In order to manage games
As a user
I want to be able to create games
And edit games that I have created

  Background:
    Given I am a user named "zapnap"

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

  Scenario: Owner aborts game during setup phase
    Given I am signed in
    And there is a pending game called "The Incident at Mariahville"
    And I am the owner of the game
    When I go to the game page for "The Incident at Mariahville"
    And I press "Abort Game"
    Then I should see "The game has been aborted"
    And there should not be a game called "The Incident at Mariahville"

  Scenario: Register user should not see game owner controls
    Given I am signed in
    And there is a pending game called "The Incident at Mariahville"
    When I go to the game page for "The Incident at Mariahville"
    Then I should not see "Abort Game"
    And I should not see "Start Game Now"

  Scenario: Owner manually starts game
    Given I am signed in
    And there is a pending game called "The Incident at Mariahville"
    And I am the owner of the game
    And the game is startable
    When I go to the game page for "The Incident at Mariahville"
    And I press "Start Game Now"
    Then the game is waiting to start
    And I should see "The game will begin shortly"

  Scenario: User fails to manually start game
    Given I am signed in
    And there is a pending game called "The Incident at Mariahville"
    And I am the owner of the game
    And the game is not startable
    When I go to the game page for "The Incident at Mariahville"
    Then I should not see "Start Game Now"
