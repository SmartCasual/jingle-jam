Feature: Bundles: multi-tiered

Background:
  Given a bundle with the following tiers:
    | Game        | Tier  |
    | Halo        | £5    |
    | The Witness | £7.50 |
    | Frogger     | £25   |

Scenario: A below-bundle donation
  When a donator makes a £3 donation
  Then a £3 donation should be recorded
  And no keys should have been assigned for that bundle

Scenario: An at-tier donation
  When a donator makes a £5 donation
  Then a £5 donation should be recorded
  And a key should be assigned for "Halo"
  But a key should not be assigned for "The Witness"
  And a key should not be assigned for "Frogger"

Scenario: An above-tier donation
  When a donator makes a £8 donation
  Then a £8 donation should be recorded
  And a key should be assigned for "Halo"
  And a key should be assigned for "The Witness"

Scenario: An at-bundle donation
  When a donator makes a £25 donation
  Then a £25 donation should be recorded
  And one key per game in the bundle should have been assigned

Scenario: A donator increases their donation above the threshold
  When a donator makes a £3 donation
  Then a £3 donation should be recorded
  And no keys should have been assigned for that bundle

  When the donator makes another £4 donation
  Then a £4 donation should be recorded
  And a key should be assigned for "Halo"
  But a key should not be assigned for "The Witness"
  And a key should not be assigned for "Frogger"

  When the donator makes another £2.50 donation
  Then a £2.50 donation should be recorded
  And a key should be assigned for "Halo"
  And a key should be assigned for "The Witness"
  But a key should not be assigned for "Frogger"

  When the donator makes another £17.50 donation
  Then a £17.50 donation should be recorded
  And a key should be assigned for "Halo"
  And a key should be assigned for "The Witness"
  And a key should be assigned for "Frogger"
