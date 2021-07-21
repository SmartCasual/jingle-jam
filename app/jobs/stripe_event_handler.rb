# TODO: Unit test this
class StripeEventHandler < ApplicationJob
  queue_as :default

  def perform(event)
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

private

  def handle_completed_checkout(checkout_session)
    customer_email_address = checkout_session.dig(:customer_details, :email)
    donator_id = checkout_session.dig(:metadata, :donator_id)
    curated_streamer_id = checkout_session.dig(:metadata, :curated_streamer_id)

    charity_splits_data = JSON.parse(checkout_session.dig(:metadata, :charity_splits) || "[]", symbolize_names: true)

    charity_splits = charity_splits_data.each_with_object([]) do |split_data, array|
      next unless (charity = Charity.find_by(id: split_data[:charity_id]))

      array << CharitySplit.new(
        charity: charity,
        amount: Money.new(split_data[:amount_decimals], checkout_session[:currency]),
      )
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
end
