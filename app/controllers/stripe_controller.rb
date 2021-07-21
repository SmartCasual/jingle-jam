# TODO: Unit (controller) test this

require "stripe_checkout"

class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook
  before_action :skip_stripe_checkout, only: :prep_checkout_session, if: -> { Rails.env.test? }

  def prep_checkout_session
    if pro_forma_donation.errors.any?
      error pro_forma_donation.errors.full_messages.to_sentence
    else
      save_donator_if_needed

      render json: { id: stripe_checkout.create_stripe_session.id }
    end
  end

  def webhook
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    payload = request.body.read
    event = Stripe::Webhook.construct_event(payload, sig_header, ENV["STRIPE_WEBHOOK_SECRET_KEY"])

    StripeEventHandler.perform_later(event.to_hash.with_indifferent_access)

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

  def donation_params
    params.require(:donation)
      .except(:manual, :lock)
      .permit(
        :amount,
        :amount_currency,
        :curated_streamer_id,
        :message,
        charity_splits_attributes: %i[
          amount_decimals
          charity_id
        ],
      )
  end

  def stripe_checkout
    @stripe_checkout = StripeCheckout.new(pro_forma_donation, success_url, cancel_url)
  end

  def skip_stripe_checkout
    save_donator_if_needed

    StripeEventHandler.perform_later(stripe_checkout.fake_stripe_checkout_event.with_indifferent_access)

    redirect_to success_url
  end

  def success_url
    build_donation_url(status: "success")
  end

  def cancel_url
    build_donation_url(status: "cancelled")
  end

  def build_donation_url(status:)
    streamer = CuratedStreamer.find_by(id: donation_params[:curated_streamer_id])
    donations_url(status: status, streamer: streamer&.twitch_username)
  end

  def save_donator_if_needed
    if current_donator.new_record?
      current_donator.save && session[:donator_id] = current_donator.id
    end
  end
end
