Feature: Bundles: simple

Background:
  Given a simple bundle priced at £25

Scenario: A below-bundle donation
  When a donator makes a £10 donation with the message "Deci-hundo"
  Then a £10 donation should be recorded with the message "Deci-hundo"
  And no keys should have been assigned for that bundle

Scenario: An at-bundle donation
  When a donator makes a £25 donation
  Then a £25 donation should be recorded
  And one key per game in the bundle should have been assigned

Scenario: An above-bundle donation
  When a donator makes a £100 donation
  Then a £100 donation should be recorded
  And one key per game in the bundle should have been assigned

Scenario: A donator increases their donation above the threshold
  When a donator makes a £10 donation
  Then a £10 donation should be recorded
  And no keys should have been assigned for that bundle
  When the donator makes another £20 donation
  Then a £20 donation should be recorded
  And one key per game in the bundle should have been assigned
