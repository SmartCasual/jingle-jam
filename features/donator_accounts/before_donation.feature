Feature: Donator accounts: before donation

Scenario: Someone signs up with an email address and password
  When someone signs up with the email address "test@example.com"
  And they confirm their email address
  And they immediately make a donation
  Then the donation should be associated with their account
  When they sign out and make a donation giving the email address "test@example.com"
  Then the donation should be associated with their account

Scenario: Someone signs up via Twitch
  When someone signs up via Twitch with the email address "test@example.com"
  And they immediately make a donation
  Then the donation should be associated with their account
  When they sign out and make a donation giving the email address "test@example.com"
  Then the donation should be associated with their account
