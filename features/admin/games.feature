@admin
Feature: Admin: games

Scenario: Adding a game
  When an admin adds a game
  Then the game should appear on the admin games list
  And there should be an admin page for that game

Scenario: Adding keys to a game
  Given a game
  When an admin adds keys to the game
  Then the keys should be on the admin page for that game

Scenario: Editing keys
  Given a game with keys
  When an admin edits a key
  Then the edits to the key should've been saved

Scenario: Deleting a key
  Given a game with keys
  When an admin deletes a key
  Then the key shouldn't be on the admin page for that game

Scenario: Editing a game
  Given a game
  When an admin edits the game
  Then the edits to the game should've been saved

Scenario: Deleting a game
  Given a game
  When an admin deletes the game
  Then the game shouldn't appear on the admin games list

@anonymous
Scenario: Anonymous user cannot access this area
  When the user goes to the admin games area
  Then they should be bounced to the admin login page

@donator
Scenario: Known donator cannot access this area
  When the user goes to the admin games area
  Then they should be bounced to the admin login page
