require "paypal/api"
require "paypal/webhook_event"

class PaypalPaymentsController < PaymentsController
  def prep_checkout_session
    super do |donation|
      create_paypal_order(donation).tap do |order_id|
        donation.paypal_order_id = order_id
      end
    end
  end

  def complete_checkout
    donation = Donation.find_by!(paypal_order_id: params[:order_id])
    Paypal::API.capture_payment_for_order(donation.paypal_order_id)
    Payment.create_and_assign(
      amount: donation.amount.cents,
      currency: donation.amount.currency.iso_code,
      paypal_order_id: donation.paypal_order_id,
    )

    render json: { status: 200 }
  end

  def webhook
    event = Paypal::WebhookEvent.new(params:, request:)
    event.verify!

    case event.data[:event_type]
    when "CHECKOUT.ORDER.COMPLETED"
      Payment.create_and_assign(
        amount: event.data.dig(:gross_amount, :value)&.gsub(/\D/, ""),
        currency: event.data.dig(:gross_amount, :currency_code),
        paypal_order_id: event.data[:id],
      )
    end

    head :ok
  rescue JSON::ParserError
    head :unprocessable_entity
  rescue WebhookEventVerificationFailed
    head :unauthorized
  end

private

  def create_paypal_order(donation)
    Paypal::API.create_order(
      intent: "CAPTURE",
      purchase_units: [{
        amount: {
          currency_code: donation.amount.currency.iso_code,
          value: donation.amount.cents,
        },
        payee: {
          email_address: ENV["PAYPAL_EMAIL_ADDRESS"],
          merchant_id: ENV["PAYPAL_MERCHANT_ID"],
        },
        description: "Jingle Jam donation",
      }],
      application_context: {
        brand_name: "Jingle Jam",
        locale: "en-GB",
        landing_page: "NO_PREFERENCE",
        shipping_preference: "NO_SHIPPING",
        user_action: "PAY_NOW",
      },
      return_url: donations_url(streamer: donation.curated_streamer&.twitch_username, status: "success"),
      cancel_url: donations_url(streamer: donation.curated_streamer&.twitch_username, status: "cancelled"),
    )
  end
end
