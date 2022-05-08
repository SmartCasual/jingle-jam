Feature: Donations on behalf of others

Scenario: A donation is made on someone else's behalf
  Given a bundle priced at £25
  When a donator makes a £10 donation
  Then a £10 donation should be recorded under the name "You"
  And no keys should have been assigned for that bundle
  When someone else makes a £20 donation on their behalf
  Then a £20 donation should be recorded under the name "Anonymous"
  And one key per game in the bundle should have been assigned
  And the £20 donation should appear as a gifted donation on the other person's donation list
