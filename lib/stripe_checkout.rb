# TODO: Unit test this, possibly move some to test files
class StripeCheckout
  def initialize(pro_forma_donation, success_url, cancel_url)
    @pro_forma_donation = pro_forma_donation
    @success_url = success_url
    @cancel_url = cancel_url
  end

  def create_stripe_session
    Stripe::Checkout::Session.create(
      payment_method_types: ["card"],
      line_items: [{
        price_data: {
          currency: @pro_forma_donation.amount.currency.iso_code,
          product_data: {
            name: "JingleJam donation",
          },
          unit_amount: @pro_forma_donation.amount.cents,
        },
        quantity: 1,
      }],
      mode: "payment",
      success_url: @success_url,
      cancel_url: @cancel_url,
      metadata: {
        donator_id: @pro_forma_donation.donator.id,
        curated_streamer_id: @pro_forma_donation.curated_streamer&.id,
        message: @pro_forma_donation.message,
        charity_splits: charity_split_json,
      },
    )
  end

  def fake_stripe_checkout_event
    {
      type: "checkout.session.completed",
      data: {
        # https://stripe.com/docs/api/checkout/sessions/object
        object: {
          id: "cs_test_yg1S98CW7T013zdCnGV3YtShqwFlfZgZPIFtsrFFSoZhG0uC7n2rtdRG",
          object: "checkout.session",
          allow_promotion_codes: nil,
          amount_subtotal: nil,
          amount_total: @pro_forma_donation.amount.cents,
          billing_address_collection: nil,
          cancel_url: @cancel_url,
          client_reference_id: nil,
          currency: nil,
          customer_details: {
            email: "j.j.donator@example.com",
            tax_exempt: "none",
            tax_ids: [],
          },
          livemode: false,
          line_items: [{
            price_data: {
              currency: @pro_forma_donation.amount.currency.iso_code,
              product_data: {
                name: "JingleJam donation",
              },
              unit_amount: @pro_forma_donation.amount.cents,
            },
            quantity: 1,
          }],
          locale: nil,
          metadata: {
            donator_id: @pro_forma_donation.donator.id,
            curated_streamer_id: @pro_forma_donation.curated_streamer&.id,
            message: @pro_forma_donation.message,
            charity_splits: charity_split_json,
          },
          mode: "payment",
          payment_intent: "pi_1EUmyo2x6R10KRrhUuJXu9m0",
          payment_method_types: ["card"],
          payment_status: "paid",
          setup_intent: nil,
          shipping: nil,
          shipping_address_collection: nil,
          submit_type: nil,
          subscription: nil,
          success_url: @success_url,
          total_details: nil,
        },
      },
    }
  end

private

  def charity_split_json
    JSON.dump(
      @pro_forma_donation.charity_splits.each_with_object([]) { |split, array|
        next unless split.charity

        array << {
          amount_decimals: split.amount.cents,
          charity_id: split.charity.id,
        }
      },
    )
  end
end
