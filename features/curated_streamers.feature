Feature: Curated streamers

Scenario: New donator donates on a curated streamer page
  Given a curated streamer
  When a donator goes to the curated streamer's page
  And they make a donation
  Then the curated streamer page should show that donation
