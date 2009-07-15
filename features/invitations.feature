Feature: Invitations
In order to attract new players to a game
As owner of the game or participant in an open game
I want to be able to invite my friends and followers

  Scenario: User invites friends to an open game
    Given I am signed in
    And there is a game called "The Incident at Mariahville"
    When I go to the new invitations page for "The Incident at Mariahville"
    And I press "jeffrafter"
    And I press "Invite Friends"
    Then I should see "Invitations have been sent"
    And an invitation should be sent to "jeffrafter"

  Scenario: User invites friends to a private game
    Given I am signed in
    And there is an invite-only game called "The Incident at Mariahville"
    When I go to the new invitations page for "The Incident at Mariahville"
    And I press "jeffrafter"
    And I press "Invite Friends"
    Then I should see "Invitations have been sent"
    And an invitation should be sent to "jeffrafter"
