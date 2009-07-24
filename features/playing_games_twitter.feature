Feature: Playing Games through Twitter
In order to participate in a game
As a user
I want to be able to make vote and quit actions via Twitter
And receive game progress messages

  Scenario: User is notified when game starts
    Given there is a game called "The Incident at Mariahville"
    And I am playing in the game called "The Incident at Mariahville"
    And the game called "The Incident at Mariahville" is startable
    When the game called "The Incident at Mariahville" starts
    Then I should receive a notification with my role

  Scenario: User is notified if game owner aborts game
    Given there is a pending game called "The Incident at Mariahville"
    And I am playing in the game called "The Incident at Mariahville"
    When the game called "The Incident at Mariahville" is aborted
    Then I should receive a notification that the game has been aborted

  Scenario: User votes to lynch a player
    Given there is a game called "The Incident at Mariahville"
    And "aaronstack" is a player in the game called "The Incident at Mariahville"
    And I am playing in the game called "The Incident at Mariahville"
    And the game called "The Incident at Mariahville" is in its "2nd" period
    When I send a public message containing "@gamebot We should kill @aaronstack"
    Then I should receive a direct message containing "We've recorded your vote"
    And the vote for "aaronstack" has been recorded

  Scenario: User asks to quit the game
    Given there is a game called "The Incident at Mariahville"
    And I am playing in the game called "The Incident at Mariahville"
    And the game called "The Incident at Mariahville" has started
    When I send a direct message containing "@gamebot quit"
    Then I should receive a direct message containing "Please login to quit the game or change your account notification settings"

  Scenario: User asks for help
    Given there is a game called "The Incident at Mariahville"
    And I am playing in the game called "The Incident at Mariahville"
    And the game called "The Incident at Mariahville" has started
    When I send a direct message containing "@gamebot help"
    Then I should receive a direct message containing "Hi, I'm @gamebot. Visit me on the web at whatever to get help or change your notification settings"

  Scenario: Werewolf user votes to kill a player
    Given there is a game called "The Incident at Mariahville"
    And "aaronstack" is a player in the game called "The Incident at Mariahville"
    And I am a "werewolf" in the game called "The Incident at Mariahville"
    And the game called "The Incident at Mariahville" is in its "1st" period
    When I send a public message containing "@gamebot Kill @aaronstack"
    Then I should receive a direct message containing "We've recorded your vote"
    And the vote for "aaronstack" has been recorded

  Scenario: User cannot vote during werewolf game phase
    Given there is a game called "The Incident at Mariahville"
    And "aaronstack" is a player in the game called "The Incident at Mariahville"
    And I am playing in the game called "The Incident at Mariahville"
    And the game called "The Incident at Mariahville" is in its "1st" period
    When I send a public message containing "@gamebot We should kill @aaronstack"
    Then I should receive a direct message containing "It's not your turn right now. Go back to sleep so the werewolves can eat you."
    And there is no vote for "aaronstack"

  Scenario: User is notified if they are killed
    Given there is a game called "The Incident at Mariahville"
    And I am playing in the game called "The Incident at Mariahville"
    And the game called "The Incident at Mariahville" is in its "2nd" period
    When I have been killed in the game called "The Incident at Mariahville"
    And the game period turns over
    Then I should receive a direct message containing "Eek they killed you. Those bastards. Hope the wolf gets em."

  Scenario: User is notified when period changes
    Given there is a game called "The Incident at Mariahville"
    And I am playing in the game called "The Incident at Mariahville"
    And the game called "The Incident at Mariahville" is in its "2nd" period
    When the game period turns over
    Then I should receive a direct message containing "The next phase of the game has begun..."

  Scenario: User is notified when the game is over
    Given there is a game called "The Incident at Mariahville"
    And I am playing in the game called "The Incident at Mariahville"
    When the game called "The Incident at Mariahville" is finished
    Then I should receive a direct message containing "The game is over"
