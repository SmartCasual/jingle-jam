Feature: Fundraisers: bundles

Scenario: Displaying the public list of bundles for a fundraiser
  Given a live bundle and a draft bundle for a fundraiser
  When I visit the fundraiser's public page
  Then I should see only the live bundle
