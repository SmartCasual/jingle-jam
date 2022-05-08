Feature: Fundraisers: overpayment modes

Scenario: "Pro bono" mode
  Given a fundraiser in pro bono mode
  When a donator goes to make a donation
  Then they are notified that any overpayment will be considered a charitable gift
  When they make a donation double the price of the bundle
  Then they are assigned 1 bundle

Scenario: "Pro se" mode
  Given a fundraiser in pro se mode
  When a donator goes to make a donation
  Then they are notified that any overpayment will be allocated to a new bundle
  When they make a donation double the price of the bundle
  Then they are assigned 2 bundles
