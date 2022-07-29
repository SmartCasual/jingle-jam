# Abstract class
class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook

  def prep_checkout_session
    set_current_donator
    update_current_donator
    save_current_donator

    @donation = build_donation

    if @donation.valid?
      id = yield @donation
    end

    if @donation.save
      render json: { id: }
    else
      error @donation.errors.full_messages.to_sentence
    end
  end

  def webhook
    raise "Not implemented"
  end

private

  def build_donation
    Donation.new(donation_params).tap do |donation|
      on_behalf_of = if params[:on_behalf_of].present?
        Donator.find_by(email_address: params[:on_behalf_of])
      end

      if on_behalf_of.present?
        donation.donator = on_behalf_of
        donation.donated_by = current_donator
      else
        donation.donator = current_donator
      end
    end
  end

  def donation_params
    params.require(:donation)
      .except(:lock, :manual)
      .permit(
        :amount_currency,
        :curated_streamer_id,
        :donator_name,
        :fundraiser_id,
        :human_amount,
        :message,
        charity_splits_attributes: %i[
          amount_decimals
          charity_id
        ],
      )
  end

  def set_current_donator
    self.current_donator = ExistingDonatorFinder.find(
      current_donator:,
      email_address: params[:donator_email_address],
    )
  end

  def update_current_donator
    current_donator.name ||= donation_params[:donator_name]
    current_donator.email_address ||= params[:donator_email_address]
  end

  def save_current_donator
    current_donator.save!

    if current_donator.previously_new_record?
      sign_in(current_donator)
      NotificationsMailer.account_created(current_donator).deliver_now
    end
  end

  def set_donator_email_if_missing(new_email_address)
    return if new_email_address.blank?
    return if current_donator.email_address.present?
    return if current_donator.email_address == new_email_address

    current_donator.update(email_address: new_email_address)
  rescue Aws::SES::Errors::MessageRejected => e
    Rollbar.error(e)
  end

  def success_url
    return_url(status: "success")
  end

  def cancel_url
    return_url(status: "cancelled")
  end

  def return_url(status:)
    if @donation.curated_streamer
      fundraiser_curated_streamer_url(@donation.fundraiser, @donation.curated_streamer, status:)
    else
      fundraiser_donations_url(@donation.fundraiser, status:)
    end
  end
end
