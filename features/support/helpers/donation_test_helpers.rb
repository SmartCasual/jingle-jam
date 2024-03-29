require_relative "../../../test/support/request_test_helpers"

module DonationTestHelpers
  include RequestTestHelpers

  def make_donation(amount = nil, stripe_options: {}, **options) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    options = {
      email_address: "test@example.com",
      expect_failure: false,
      fundraiser: nil,
      message: nil,
      name: nil,
      navigate: false,
      on_behalf_of: nil,
      paypal: false,
      split: {},
      submit: true,
    }.merge(options)

    stripe_options = {
      stub: true,
    }.merge(stripe_options)

    if options[:navigate]
      fundraiser = (options[:fundraiser] || Fundraiser.active.open.first || create(:fundraiser, :active, :with_live_bundle))
      go_to_homepage || refresh
      click_on fundraiser.name
      click_on "Donate here!"
    end

    amount ||= fundraiser.bundles.first&.highest_tier&.price

    select amount.currency.iso_code, from: "Currency", wait: 5
    fill_in "Amount", with: amount.to_s, fill_options: { clear: :backspace }
    fill_in "Message", with: options[:message] if options[:message]
    fill_in "Name", with: options[:name] if options[:name]
    fill_in "Email address", with: options[:email_address] if options[:email_address]

    if (on_behalf_of = options[:on_behalf_of])
      on_behalf_of = on_behalf_of.email_address if on_behalf_of.respond_to?(:email_address)
      fill_in "On behalf of", with: on_behalf_of
    end

    if (split = options[:split]).present?
      split.each do |charity, split_amount|
        find("li[data-charity-id='#{charity.id}'] input.manual")
          .set(split_amount.to_s, clear: :backspace)

        within "li[data-charity-id='#{charity.id}']" do
          check "Lock slider"
        end
      end
    end

    if options[:submit]
      donation_count = Donation.count
      payment_count = Payment.count

      if options[:paypal]
        main_window = current_window

        page.find("#paypal-donate-button").click

        unless TestData[:fake_payment_providers]
          retry_for(seconds: 10, exception: [Capybara::WindowError, Selenium::WebDriver::Error::NoSuchWindowError]) do
            switch_to_window { title == "PayPal" }
          end

          fill_in "Email address", with: ENV.fetch("PAYPAL_TEST_DONATOR_EMAIL_ADDRESS", nil), wait: 30
          click_on "Next"

          fill_in "Password", with: ENV["PAYPAL_TEST_DONATOR_EMAIL_ADDRESS"].split("@").first, wait: 10
          click_button "Log In"

          click_on "Accept Cookies", wait: 10
          click_button "Pay Now", wait: 10

          switch_to_window(main_window)
        end

        return if options[:expect_failure]

        wait_for { Donation.count == (donation_count + 1) }
      else
        if stripe_options.delete(:stub)
          stub_stripe_session_creation(amount:)
        end

        click_on "Card payment"
        return if options[:expect_failure]

        wait_for { Donation.count == (donation_count + 1) }

        if TestData[:fake_payment_providers]
          simulate_stripe_payment_webhook(Donation.last, **stripe_options)
        else
          fill_in "Email", with: "test@example.com", wait: 10
          fill_in "cardNumber", with: "4242424242424242"
          fill_in "cardExpiry", with: "01/49"
          fill_in "cardCvc", with: "123"
          fill_in "Name on card", with: "Testy McTest"
          fill_in "billingPostalCode", with: "12345"

          click_on "Donate #{amount.format}"
        end

        expect(page).to have_css(".logo-box", wait: 10)
      end

      wait_for { Payment.count == (payment_count + 1) }
      wait_for { KeyAssignment::RequestProcessor.finished_backlog? }

      refresh
    end
  end

  def simulate_stripe_payment_webhook(donation, event: "payment_intent.succeeded", email_address: nil, payment_intent_id: nil)
    timestamp = Time.zone.now.to_i

    simulate_stripe_webhook(
      timestamp:,
      payload: stripe_webhook_payload(
        timestamp:,
        event_type: event,
        object: stripe_payment_intent_object(
          payment_intent_id: payment_intent_id || donation.stripe_payment_intent_id,
          amount: donation.amount_decimals,
          currency: donation.amount_currency,
          email_address:,
        ),
      ),
    )
  end
end

World(DonationTestHelpers)
