@admin
@data_entry
Feature: Admin: bundles

Scenario: Adding a bundle
  When an admin adds a bundle
  Then the bundle should appear on the admin bundles list
  And there should be an admin page for that bundle

Scenario: Adding games to a bundle
  Given a draft bundle priced at £20
  And these games:
    | The Witness  |
    | Doom Eternal |
  When an admin adds these games to the bundle:
    | Game         | Tier |
    | The Witness  | £20  |
    | Doom Eternal | £10  |
  Then the games with their tiers should be on the admin page for that bundle

Scenario: Editing game entries
  Given a draft bundle
  When an admin edits a game entry
  Then the edits to the game entry should've been saved

Scenario: Deleting a game entry
  Given a draft bundle
  When an admin deletes a game entry
  Then the game entry shouldn't be on the admin page for that bundle

Scenario: Editing a bundle
  Given a draft bundle
  When an admin edits the bundle
  Then the edits to the bundle should've been saved

Scenario: Deleting a bundle
  Given a draft bundle
  When an admin deletes the bundle
  Then the bundle shouldn't appear on the admin bundles list

Scenario: Publishing a draft bundle
  Given a draft bundle
  When an admin publishes the bundle
  Then the bundle should appear on the admin bundles list as live

Scenario: Retracting a live bundle
  Given a live bundle
  When an admin retracts the bundle
  Then the bundle should appear on the admin bundles list as draft

Scenario: Attempting to edit a live bundle
  Given a live bundle
  Then the bundles list should not have an edit link for that bundle
  When an admin attempts to edit the bundle anyway
  Then the admin should be redirected to the bundles list

Scenario: Changing the price of a game tier within a bundle
  Given a draft bundle with tiers
  When an admin changes the price of a game tier within a bundle
  Then the price of the game tier should've been saved

Scenario: Deleting a tier within a bundle
  Given a draft bundle with tiers
  When an admin deletes a tier within a bundle
  Then the tier shouldn't appear on the admin page for that bundle

@anonymous
Scenario: Anonymous user cannot access this area
  When the user goes to the admin bundles area
  Then they should be bounced to the admin login page

@donator
Scenario: Known donator cannot access this area
  When the user goes to the admin bundles area
  Then they should be bounced to the admin login page
