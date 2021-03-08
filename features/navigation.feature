Feature: Navigation

Scenario: Navigating around the major donator areas
  When a donator visits "/"
  Then they should see the header "Welcome to Jingle Jam!"
  When a donator clicks on "Your game keys"
  Then they should see the header "Your game keys"
  When a donator clicks on "Your donations"
  Then they should see the header "Your donations"
  When a donator clicks on "Homepage"
  Then they should see the header "Welcome to Jingle Jam!"
