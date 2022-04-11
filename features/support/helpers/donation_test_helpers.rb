require_relative "../../../test/support/request_test_helpers"

module DonationTestHelpers
  include RequestTestHelpers

  def make_donation(amount, name: nil, split: {}, message: nil, navigate: false, submit: true, on_behalf_of: nil) # rubocop:disable Metrics/CyclomaticComplexity
    if navigate
      go_to_homepage
      click_on "Donate here!"
    end

    select amount.currency.iso_code, from: "Currency"
    fill_in "Amount", with: amount.to_s, fill_options: { clear: :backspace }
    fill_in "Message", with: message if message
    fill_in "Name", with: name if name

    if on_behalf_of.present?
      fill_in "On behalf of", with: on_behalf_of.email_address
    end

    if split.present?
      split.each do |charity, split_amount|
        find("li[data-charity-id='#{charity.id}'] input.manual")
          .set(split_amount.to_s, clear: :backspace)

        within "li[data-charity-id='#{charity.id}']" do
          check "Lock slider"
        end
      end
    end

    if submit
      donation_count = Donation.count
      click_on "Card payment"
      wait_for(Donation, :count, (donation_count + 1))
      simulate_stripe_payment_webhook(Donation.last)
      refresh
    end
  end

  def wait_for(target, method, expectation, timeout: 10, step: 0.1)
    time_waited = 0

    while target.public_send(method) != expectation
      if time_waited >= timeout
        raise "#{target}.#{method} didn't equal #{expectation} within #{timeout}s"
      end

      sleep step
      time_waited += step
    end
  end

  def simulate_stripe_payment_webhook(donation, event: "payment_intent.succeeded")
    timestamp = Time.zone.now.to_i

    simulate_stripe_webhook(
      timestamp:,
      payload: stripe_webhook_payload(
        timestamp:,
        event_type: event,
        object: stripe_payment_intent_object(
          payment_intent_id: donation.stripe_payment_intent_id,
          amount: donation.amount_decimals,
          currency: donation.amount_currency,
        ),
      ),
    )
  end
end

World(DonationTestHelpers)
