@twitch_embed_enabled
Feature: Streaming: twitch

Scenario: Main Yogscast twitch is embedded on the homepage
  When the user visits the homepage
  Then the main Yogscast twitch should be embedded on the page
