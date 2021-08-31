Feature: Curated streamers

@stripe
Scenario: New donator donates on a curated streamer page
  Given a curated streamer
  When a donator goes to the curated streamer's page
  And they make a donation
  Then the curated streamer page should show that donation

@twitch_embed_enabled
Scenario: Curated streams are embedded on their page
  Given a curated streamer
  When a donator goes to the curated streamer's page
  Then the curated streamer's twitch should be embedded on the page

Scenario: Stream admin views donation stats
  Given a some donations for a curated streamer
  And some other donations
  Then a stream admin for that streamer should see the relevant donations on the stream admin page
  And a stream admin for a different streamer should not be able to see the stream admin page
  And a regular user should not be able to see the stream admin page
