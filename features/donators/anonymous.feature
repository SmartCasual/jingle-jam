Feature: Donators: anonymous

Scenario: A below-bundle anonymous donation
  Given a simple bundle priced at £25
  When an anonymous donator makes a £10 donation with the message "Deci-hundo"
  Then a £10 donation should be recorded with the message "Deci-hundo"
  And no keys should have been assigned for that bundle
