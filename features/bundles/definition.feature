Feature: Bundles: definition

Scenario: A single, simple bundle
  Given a simple bundle priced at £25
  Then a donator should see 1 bundle
  And a donator should see the bundle priced at £25

Scenario: Multiple simple bundles
  Given a simple bundle priced at £25
  And a simple bundle priced at £10
  Then a donator should see 2 bundles
  And a donator should see a bundle priced at £25
  And a donator should see a bundle priced at £10

Scenario: A single, tiered bundle
  Given a tiered bundle priced at £25 with the following tiers:
    | Game        | Tier price   |
    | Halo        | £5           |
    | The Witness | £7.50        |
    | Frogger     | bundle price |
  Then a donator should see 1 bundle
  And a donator should see the bundle priced at £25 with the following tiers:
    | Game        | Tier price   |
    | Halo        | £5           |
    | The Witness | £7.50        |
    | Frogger     | bundle price |
