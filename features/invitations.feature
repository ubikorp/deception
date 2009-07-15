Feature: Invitations
In order to attract new players to a game
As owner of the game or participant in an open game
I want to be able to invite my friends and followers

  Scenario: User invites friends to an open game
    Given I am signed in
    And there is a pending game called "The Incident at Mariahville"
    When I go to the new invitations page for "The Incident at Mariahville"
    And I fill in "invitation-ids" with "jeffrafter, Sutto"
    And I press "Send Invitations"
    Then I should see "Invitations have been sent"
    And an invitation for "The Incident at Mariahville" should be sent to "jeffrafter"
    And an invitation for "The Incident at Mariahville" should be sent to "Sutto"

  Scenario: User invites friends to a private game that they own
    Given I am signed in
    And there is an invite-only game called "The Incident at Mariahville"
    And I am the owner of the game called "The Incident at Mariahville"
    When I go to the new invitations page for "The Incident at Mariahville"
    And I fill in "invitation-ids" with "jeffrafter, Sutto"
    And I press "Send Invitations"
    Then I should see "Invitations have been sent"
    And an invitation for "The Incident at Mariahville" should be sent to "jeffrafter"
    And an invitation for "The Incident at Mariahville" should be sent to "Sutto"

  Scenario: User is not able to invite friends to a private game
    Given I am signed in
    And there is an invite-only game called "The Incident at Mariahville"
    When I go to the new invitations page for "The Incident at Mariahville"
    Then I am redirected to the login page
