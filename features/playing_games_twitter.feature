Feature: Playing Games through Twitter
In order to participate in a game
As a user
I want to be able to make vote and quit actions via Twitter
And receive game progress messages

  Background:
    Given I am a user named "zapnap"

  Scenario: User is notified when game starts and assigned a role
    Given there is a game called "The Incident at Mariahville"
    And I am a "villager" in the game
    And the game is startable
    When the game starts
    Then I should receive a direct message
    And the direct message should contain "game has started"
    And the direct message should contain "Villager"

  Scenario: User is notified if game owner aborts game
    Given there is a pending game called "The Incident at Mariahville"
    And I am a "player" in the game
    When the game is aborted
    Then I should receive a direct message
    And the direct message should contain "has been cancelled"

  Scenario: User votes to lynch a player
    Given there is a game called "The Incident at Mariahville"
    And "aaronstack" is a "villager" in the game
    And I am a "player" in the game
    And the game is in its "2nd" period
    When I send a public message containing "We should kill @aaronstack"
    Then I should receive a direct message
    And the direct message should contain "We've recorded your vote"
    And the vote for "aaronstack" has been recorded

  Scenario: User asks to quit the game
    Given there is a game called "The Incident at Mariahville"
    And I am a "player" in the game
    And the game has started
    When I send a direct message containing "quit"
    Then I should receive a direct message
    And the direct message should contain "visit the website"

  Scenario: User asks for help
    Given there is a game called "The Incident at Mariahville"
    And I am a "player" in the game
    And the game has started
    When I send a direct message containing "help"
    Then I should receive a direct message
    And the direct message should contain "I don't understand"

  Scenario: Werewolf user votes to kill a player
    Given there is a game called "The Incident at Mariahville"
    And "aaronstack" is a "villager" in the game
    And I am a "werewolf" in the game
    And the game is in its "1st" period
    When I send a public message containing "Kill @aaronstack"
    Then I should receive a direct message
    And the direct message should contain "We've recorded your vote"
    And the vote for "aaronstack" has been recorded

  Scenario: Villager cannot vote during werewolf game phase
    Given there is a game called "The Incident at Mariahville"
    And "aaronstack" is a "villager" in the game
    And I am a "villager" in the game
    And the game is in its "1st" period
    When I send a public message containing "We should kill @aaronstack"
    Then I should receive a direct message
    And the direct message should contain "Can't record your vote"
    And there is no vote for "aaronstack"

  Scenario: User is notified if they are killed
    Given there is a game called "The Incident at Mariahville"
    And I am a "villager" in the game
    And the game is in its "2nd" period
    When I have been killed in the game
    And the game period turns over
    Then I should receive a direct message
    And the direct message should contain "they killed you"

  Scenario: User is notified when period changes
    Given there is a game called "The Incident at Mariahville"
    And I am a "player" in the game
    And the game is in its "2nd" period
    When the game period turns over
    Then I should receive a direct message
    And the direct message should contain "There were no werewolf attacks last night. Now it's day time again."

  Scenario: User is notified when the game is over
    Given there is a game called "The Incident at Mariahville"
    And I am a "villager" in the game
    And the game has started
    When the game is finished
    Then I should receive a direct message
    And the direct message should contain "end of the game"

  Scenario: User disables notifications
    Given there is a game called "The Incident at Mariahville"
    And I am a "player" in the game
    And I have disabled notifications
    And the game has started
    When the game is finished
    Then I should not receive a direct message containing "end of the game"
    And I should not receive a direct message containing "found you out"
