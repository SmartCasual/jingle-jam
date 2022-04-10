@admin
@data_entry
Feature: Admin: bundle definitions

Scenario: Adding a bundle definition
  When an admin adds a bundle definition
  Then the bundle definition should appear on the admin bundle definitions list
  And there should be an admin page for that bundle definition

Scenario: Adding games to a bundle definition
  Given a bundle definition
  And these games:
    | The Witness  |
    | Doom Eternal |
  When an admin adds these games to the bundle definition:
    | Game         | Tier price   |
    | The Witness  | bundle price |
    | Doom Eternal | £10          |
  Then the games with their tiers should be on the admin page for that bundle definition

Scenario: Editing game entries
  Given a bundle definition
  When an admin edits a game entry
  Then the edits to the game entry should've been saved

Scenario: Deleting a game entry
  Given a bundle definition
  When an admin deletes a game entry
  Then the game entry shouldn't be on the admin page for that bundle definition

Scenario: Editing a bundle definition
  Given a bundle definition
  When an admin edits the bundle definition
  Then the edits to the bundle definition should've been saved

Scenario: Deleting a bundle definition
  Given a bundle definition
  When an admin deletes the bundle definition
  Then the bundle definition shouldn't appear on the admin bundle definitions list

Scenario: Publishing a draft bundle definition
  Given a draft bundle definition
  When an admin publishes the bundle definition
  Then the bundle definition should appear on the admin bundle definitions list as live

Scenario: Retracting a live bundle definition
  Given a live bundle definition
  When an admin retracts the bundle definition
  Then the bundle definition should appear on the admin bundle definitions list as draft

@anonymous
Scenario: Anonymous user cannot access this area
  When the user goes to the admin bundle definitions area
  Then they should be bounced to the admin login page

@donator
Scenario: Known donator cannot access this area
  When the user goes to the admin bundle definitions area
  Then they should be bounced to the admin login page
