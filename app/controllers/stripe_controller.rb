# rubocop:disable all
class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook
  before_action :skip_stripe_checkout, only: :prep_checkout_session, if: -> { Rails.env.test? }

  def prep_checkout_session
    if pro_forma_donation.errors.any?
      error pro_forma_donation.errors.full_messages.to_sentence
    else
      save_donator_if_needed

      render json: { id: create_stripe_session.id }
    end
  end

  def webhook
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    payload = request.body.read
    event = Stripe::Webhook.construct_event(payload, sig_header, ENV["STRIPE_WEBHOOK_SECRET_KEY"])

    handle_event(event.to_hash.deep_symbolize_keys)

    head :ok
  rescue JSON::ParserError
    head :unprocessable_entity
  rescue Stripe::SignatureVerificationError
    head :unauthorized
  end

private

  def pro_forma_donation
    @pro_forma_donation ||= Donation.new(donation_params.merge(donator: current_donator))
  end

  def charity_split_json
    JSON.dump(
      pro_forma_donation.charity_splits.each_with_object([]) { |split, array|
        next unless split.charity

        array << {
          amount_decimals: split.amount.cents,
          charity_id: split.charity.id,
        }
      }
    )
  end

  def donation_params
    params.require(:donation)
      .except(:manual, :lock)
      .permit(
        :amount,
        :amount_currency,
        :curated_streamer_id,
        :message,
        charity_splits_attributes: [
          :amount_decimals,
          :charity_id,
        ],
      )
  end

  def handle_completed_checkout(checkout_session)
    customer_email_address = checkout_session.dig(:customer_details, :email)
    donator_id = checkout_session.dig(:metadata, :donator_id)
    curated_streamer_id = checkout_session.dig(:metadata, :curated_streamer_id)

    charity_splits_data = JSON.parse(checkout_session.dig(:metadata, :charity_splits) || "[]", symbolize_names: true)

    charity_splits = charity_splits_data.each_with_object([]) do |split_data, array|
      if (charity = Charity.find_by(id: split_data[:charity_id]))
        array << CharitySplit.new(
          charity: charity,
          amount: Money.new(split_data[:amount_decimals], checkout_session[:currency]),
        )
      end
    end

    donator = Donator.find(donator_id)
    curated_streamer = CuratedStreamer.find(curated_streamer_id) if curated_streamer_id.present?

    donator.update(email_address: customer_email_address) unless donator.email_address == customer_email_address

    donation = Donation.new(
      amount: Money.new(checkout_session[:amount_total], checkout_session[:currency]),
      message: checkout_session.dig(:metadata, :message),
      donator: donator,
      curated_streamer: curated_streamer,
      stripe_checkout_session_id: checkout_session[:id],
      charity_splits: charity_splits,
    )

    if checkout_session[:payment_status] == "paid"
      donation.confirm_payment!
      BundleCheckJob.perform_later(donator.id)
      NotificationsMailer.donation_received(donator).deliver_now
      # TODO: Notify webhooks
    else
      donation.save!
    end
  end

  def handle_async_payment(checkout_session, success: true)
    return unless (donation = Donation.find_by(stripe_checkout_session_id: checkout_session[:id]))

    if success
      donation.confirm_payment!
      BundleCheckJob.perform_later(donation.donator_id)
      # TODO: Notify webhooks
    else
      donation.cancel!
    end

    # TODO: Notify user
  end

  def handle_event(event)
    event_data = event.dig(:data, :object)

    case event[:type]
    when "checkout.session.completed"
      handle_completed_checkout(event_data)
    when "checkout.session.async_payment_succeeded"
      handle_async_payment(event_data)
    when "checkout.session.async_payment_failed"
      handle_async_payment(event_data, success: false)
    end
  end

  def skip_stripe_checkout
    save_donator_if_needed
    handle_event(fake_stripe_checkout_event)

    redirect_to success_url
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
          amount_total: pro_forma_donation.amount.cents,
          billing_address_collection: nil,
          cancel_url: cancel_url,
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
              currency: donation_params[:amount_currency],
              product_data: {
                name: "JingleJam donation",
              },
              unit_amount: pro_forma_donation.amount.cents,
            },
            quantity: 1,
          }],
          locale: nil,
          metadata: {
            donator_id: pro_forma_donation.donator.id,
            curated_streamer_id: pro_forma_donation.curated_streamer&.id,
            message: pro_forma_donation.message,
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
          success_url: success_url,
          total_details: nil,
        },
      },
    }
  end

  def success_url
    build_donation_url(status: "success")
  end

  def cancel_url
    build_donation_url(status: "cancelled")
  end

  def build_donation_url(status:)
    donations_url(status: status, streamer: CuratedStreamer.find_by(id: donation_params[:curated_streamer_id])&.twitch_username)
  end

  def save_donator_if_needed
    if current_donator.new_record?
      current_donator.save && session[:donator_id] = current_donator.id
    end
  end

  def create_stripe_session
    Stripe::Checkout::Session.create(
      payment_method_types: ["card"],
      line_items: [{
        price_data: {
          currency: donation_params[:amount_currency],
          product_data: {
            name: "JingleJam donation",
          },
          unit_amount: pro_forma_donation.amount.cents,
        },
        quantity: 1,
      }],
      mode: "payment",
      success_url: success_url,
      cancel_url: cancel_url,
      metadata: {
        donator_id: pro_forma_donation.donator.id,
        curated_streamer_id: pro_forma_donation.curated_streamer&.id,
        message: pro_forma_donation.message,
        charity_splits: charity_split_json,
      },
    )
  end
end
