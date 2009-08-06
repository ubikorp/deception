Feature: User Settings
In order to manage my user account
As a user
I want to view account details
And change my notification settings

  Background:
    Given I am a user named "zapnap"

  Scenario: User changes their notification settings
    Given I am signed in
    When I go to the settings page
    And I uncheck "Acknowledge My Game Actions"
    And I press "Update Account Settings"
    Then I should see "Updated"
    And I should not be sent "reply" notifications
