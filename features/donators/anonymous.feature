Feature: Donators: anonymous

@bundles
Scenario: A below-bundle anonymous donation
  Given the bundle price is set to £25
  When an anonymous donator makes a £10 donation with the message "Deci-hundo"
  Then a £10 donation should be recorded with the message "Deci-hundo"
  And no bundles should have been assigned
