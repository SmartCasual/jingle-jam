module StripeTestHelpers
  def stub_stripe_return_email_address(email_address, &)
    VCR.use_cassette("prep_stripe_checkout_session", erb: { email_address: }, &)
  end
end
