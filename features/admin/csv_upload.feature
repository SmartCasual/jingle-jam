Feature: Admin: CSV upload

@admin
@data_entry
Scenario: Admin uploads a well-formed CSV
  When an admin uploads a CSV with game keys for a game
  Then the game keys should be added to that game
