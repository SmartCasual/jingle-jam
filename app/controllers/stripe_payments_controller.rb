class StripePaymentsController < PaymentsController
  def prep_checkout_session
    super do |donation|
      stripe_session = create_stripe_session(donation)

      donation.stripe_payment_intent_id = stripe_session.payment_intent
      set_donator_email_if_missing(stripe_session.customer_email)

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
      if (donation = Donation.find_by(stripe_payment_intent_id: event_data[:id]))
        self.current_donator = donation.donator
        set_stripe_customer_id_if_missing(event_data[:customer])
        set_donator_email_if_missing(event_data.dig(:charges, :data, 0, :billing_details, :email))
      end

      Payment.create_and_assign(
        amount: event_data[:amount],
        currency: event_data[:currency],
        stripe_payment_intent_id: event_data[:id],
      )
    end

    head :ok
  rescue JSON::ParserError
    Rails.logger.debug("Stripe webhook: invalid JSON")
    head :unprocessable_entity
  rescue Stripe::SignatureVerificationError
    Rails.logger.debug("Stripe webhook: invalid signature")
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

  def set_stripe_customer_id_if_missing(stripe_customer_id)
    return if stripe_customer_id.blank?
    return if current_donator.stripe_customer_id.present?

    current_donator.update(stripe_customer_id:)
  end
end
