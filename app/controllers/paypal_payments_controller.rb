require "paypal/webhooks"

class PaypalPaymentsController < PaymentsController
  def prep_checkout_session
    super do |donation|
      create_paypal_order(donation).tap do |order|
        donation.paypal_order_id = order
      end
    end
  rescue Paypal::REST::ClientError => e
    Rails.logger.error(e.message)
    head :unprocessable_entity
  end

  def complete_checkout
    donation = Donation.find_by!(paypal_order_id: params[:order_id])

    response = Paypal::REST.capture_payment_for_order(donation.paypal_order_id, full_response: true)
    set_donator_email_if_missing(response.dig(:payer, :email_address))

    Payment.create_and_assign(
      amount: donation.amount.cents,
      currency: donation.amount.currency.iso_code,
      paypal_order_id: donation.paypal_order_id,
    )

    render json: { status: 200 }
  rescue Paypal::REST::ClientError => e
    Rails.logger.error(e.message)
    head :unprocessable_entity
  end

  def webhook
    event = Paypal::Webhooks::Event.new(params:, request:)
    event.verify!

    case event.type
    when "CHECKOUT.ORDER.COMPLETED"
      set_donator_email_if_missing(event.data.dig(:payer, :email_address))

      Payment.create_and_assign(
        amount: event.data.dig(:gross_amount, :value)&.gsub(/\D/, ""),
        currency: event.data.dig(:gross_amount, :currency_code),
        paypal_order_id: event.data[:id],
      )
    end

    head :ok
  rescue JSON::ParserError
    head :unprocessable_entity
  rescue Paypal::Webhooks::EventVerificationFailed
    head :unauthorized
  end

private

  def create_paypal_order(donation)
    Paypal::REST.create_order(
      intent: "CAPTURE",
      purchase_units: [{
        amount: {
          currency_code: donation.amount.currency.iso_code,
          value: donation.amount.format(symbol: false),
        },
        payee: {
          email_address: ENV.fetch("PAYPAL_EMAIL_ADDRESS", nil),
          merchant_id: ENV.fetch("PAYPAL_MERCHANT_ID", nil),
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
      return_url: success_url,
      cancel_url:,
    )
  end
end
