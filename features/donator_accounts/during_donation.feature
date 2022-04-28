Feature: Donator accounts: During donation

Scenario: Donator does not give a name or an email address
  When a donator makes a donation without giving a name or an email address
  Then an anonymous account should have been made for the donator
  And the donator should have been logged in
  And the donator should see a token log-in link on the page
  When the donator puts that link aside
  And the donator logs out
  Then the donator should be able to log back in with their link

Scenario: Donator gives a name but no email address
  When a donator makes a donation giving a name but no email address
  Then an account should have been made for the donator with their name
  And the donator should have been logged in
  And the donator should see a token log-in link on the page
  When the donator puts that link aside
  And the donator logs out
  Then the donator should be able to log back in with their link

Scenario: Donator gives an email address
  When a donator makes a donation giving an email address
  Then an account should have been made for the donator with their email address
  And the donator should have been logged in
  And the donator should see a token log-in link on the page
  And the donator should have been sent a token log-in link via email
  But the donator's email address should not be confirmed
  When the donator logs out
  Then the donator should be able to log back in with the link in the email
  And the donator's email address should now be confirmed

Scenario: Donator's email address comes from Stripe
  When a donator makes a donation giving an email address from Stripe
  Then an account should have been made for the donator with their email address
  And the donator's email address should not be confirmed

Scenario: Donator's email address comes from Paypal
  When a donator makes a donation giving an email address from Paypal
  Then an account should have been made for the donator with their email address
  And the donator's email address should not be confirmed
