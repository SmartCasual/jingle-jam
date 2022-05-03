Feature: Log in via token

Scenario: Donator with a confirmed email address requests a log in URL
  Given a donator with a confirmed email address
  When they request a log in URL
  Then they should receive a log in URL

Scenario: Donator with an unconfirmed email address requests a log in URL
  Given a donator with an unconfirmed email address
  When they request a log in URL
  Then they should not receive a log in URL

Scenario: Someone requests a log in URL for a non-existent account
  When someone requests a log in URL for a non-existent account
  Then they should not receive a log in URL
