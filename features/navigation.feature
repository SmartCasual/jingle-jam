Feature: Navigation

Scenario: Navigating around the major donator areas
  When a donator visits "/"
  Then they should see the header "Welcome to Jingle Jam!"
  When a donator clicks on nav link "Donate here!"
  Then they should see the header "Your donations"
  When a donator clicks on the main logo
  Then they should see the header "Welcome to Jingle Jam!"

@donator
Scenario: Navigating around the major donator areas while logged in
  When a donator visits "/"
  Then they should see the header "Welcome to Jingle Jam!"
  When a donator clicks on nav link "Your game keys"
  Then they should see the header "Your game keys"
  When a donator clicks on nav link "Your donations"
  Then they should see the header "Your donations"
  When a donator clicks on the main logo
  Then they should see the header "Welcome to Jingle Jam!"
