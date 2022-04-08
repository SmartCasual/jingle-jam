# Abstract class
class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook

  def prep_checkout_session
    save_donator_if_needed

    donation = Donation.new(donation_params.merge(donator: current_donator))

    if donation.valid?
      id = yield donation
    end

    if donation.save
      render json: { id: }
    else
      error donation.errors.full_messages.to_sentence
    end
  end

  def webhook
    raise "Not implemented"
  end

private

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

  def save_donator_if_needed
    if current_donator.new_record?
      current_donator.save && session[:donator_id] = current_donator.id
    end
  end
end
