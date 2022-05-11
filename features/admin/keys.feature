@admin
Feature: Admin: keys

Scenario: A key summary is shown to admins
  Given 3 unassigned keys for the game "Halo"
  And 2 unassigned keys for the game "Fire Emblem"
  And 2 assigned keys for the game "Halo"
  And 3 assigned keys for the game "Fire Emblem"
  Then a summary should be available on the game index page
  And a summary should be available on the game show page
