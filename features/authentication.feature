Feature: Authentication
In order to create and edit games
As a user
I want to sign in with Twitter

  Scenario: Login via Twitter
    When I go to "the homepage"
    And I follow "Sign in with Twitter"
    And Twitter authorizes me
    Then I should see "Logged in as"

  Scenario: Checking login status
    Given I am signed in
    When I go to "the homepage"
    Then I should see "Logged in as"

  Scenario: Log out
    Given I am signed in
    When I go to "the homepage"
    And I follow "Log out"
    Then I should see "Sign in with Twitter"
