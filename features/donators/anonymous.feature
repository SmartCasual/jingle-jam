Feature: Donators: anonymous

Scenario: A below-bundle anonymous donation
  Given a simple bundle priced at £25
  When an anonymous donator makes a £10 donation with the message "Deci-hundo"
  Then a £10 donation should be recorded with the message "Deci-hundo"
  And no keys should have been assigned for that bundle

Scenario: An at-bundle anonymous donation
  Given a simple bundle priced at £25
  When an anonymous donator makes a £25 donation
  Then a £25 donation should be recorded
  And one key per game in the bundle should have been assigned

Scenario: An above-bundle anonymous donation
  Given a simple bundle priced at £25
  When an anonymous donator makes a £100 donation
  Then a £100 donation should be recorded
  And one key per game in the bundle should have been assigned

Scenario: A anonymous donator increases their donation above the threshold
  Given a simple bundle priced at £25
  When an anonymous donator makes a £10 donation
  Then a £10 donation should be recorded
  And no keys should have been assigned for that bundle
  When the anonymous donator makes another £20 donation
  Then a £20 donation should be recorded
  And one key per game in the bundle should have been assigned
