Feature: Admin: Bulk key entry

@admin
@data_entry
Scenario: Admin enters a well-formed list of keys
  When an admin enters a list of game keys for a game
  Then the game keys should be added to that game
