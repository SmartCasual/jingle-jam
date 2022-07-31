Feature: Curated streamers

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

Scenario: Curated streamers are listed on the homepage
  Given several curated streamers
  Then links to the curated streamers should be listed on the homepage

Scenario: Curated streamers get shorter URLs
  Given a curated streamer
  But no active fundraisers
  When a donator goes to the curated streamer's shorter URL
  Then the donator should be informed that there are no active fundraisers
  Given one active fundraiser
  When a donator goes to the curated streamer's shorter URL
  Then the donator should be redirected to the curated streamer's page for the active fundraiser
  Given a second active fundraiser
  When a donator goes to the curated streamer's shorter URL
  Then the donator should be offered links to the curated streamer's page for both active fundraisers
