class StripePaymentsController < PaymentsController
  def prep_checkout_session
    super do |donation|
      stripe_session = create_stripe_session(donation)
      donation.stripe_payment_intent_id = stripe_session.payment_intent
      stripe_session.id
    end
  end

  def webhook
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    payload = request.body.read
    event = Stripe::Webhook.construct_event(payload, sig_header, ENV["STRIPE_WEBHOOK_SECRET_KEY"])&.to_hash

    event_data = event.dig(:data, :object)

    case event[:type]
    when "payment_intent.succeeded"
      Payment.create_and_assign(
        amount: event_data[:amount],
        currency: event_data[:currency],
        stripe_payment_intent_id: event_data[:id],
      )
    end

    head :ok
  rescue JSON::ParserError
    head :unprocessable_entity
  rescue Stripe::SignatureVerificationError
    head :unauthorized,
      "WWW-Authenticate" => 'Stripe-Signature realm="Stripe webhooks"'
  end

private

  def create_stripe_session(donation)
    Stripe::Checkout::Session.create(
      payment_method_types: ["card"],
      line_items: [{
        price_data: {
          currency: donation.amount.currency.iso_code,
          product_data: {
            name: "Jingle Jam donation",
          },
          unit_amount: donation.amount.cents,
        },
        quantity: 1,
      }],
      mode: "payment",
      submit_type: "donate",
      success_url: donations_url(streamer: donation.curated_streamer&.twitch_username, status: "success"),
      cancel_url: donations_url(streamer: donation.curated_streamer&.twitch_username, status: "cancelled"),
      customer: current_donator.stripe_customer_id,
    )
  end
end
