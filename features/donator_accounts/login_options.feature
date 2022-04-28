Feature: Donator accounts: login options

Scenario: Donator provides an email address but no password
  Given a donator is logged in
  When the donator provides an email address but no password
  Then they should receive a confirmation email
  When they confirm their email address
  Then they should still not be able to log in via the email & password login page

Scenario: Donator provides an email address and password
  Given a donator is logged in
  When the donator provides an email address and password
  Then they should receive a confirmation email
  When they confirm their email address
  Then they should be able to log in via the email & password login page
