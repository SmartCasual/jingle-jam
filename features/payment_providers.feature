# These features should not be run during the normal test suite
# as they interact with real payment providers.
#
# You will need to have set up appropriate environment variables
# for Stripe and/or Paypal.
#
# HTTP requests will NOT be intercepted.
#
@real_payment_providers
Feature: Payment providers

Scenario: Donation via PayPal
  When a donator makes a donation via paypal
  Then the donation should be recorded
  And the donation should have a paypal ID associated with it

# For Stripe you need to run
# stripe listen --forward-to localhost:30001/stripe/webhook
# and ensure that your webhook signing secret env var matches.
Scenario: Donation via Stripe
  When a donator makes a donation via stripe
  Then the donation should be recorded
  And the donation should have a stripe ID associated with it
