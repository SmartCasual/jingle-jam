class PaymentAssignmentJob < ApplicationJob
  queue_as :default

  def perform(payment_id, provider:)
    payment = Payment.find(payment_id)

    donation = case provider
    when :stripe
      Donation.find_by(stripe_payment_intent_id: payment.stripe_payment_intent_id)
    when :paypal
      Donation.find_by(paypal_order_id: payment.paypal_order_id)
    end

    if donation.nil?
      message = "Missing donation for `#{payment.stripe_payment_intent_id}`"
      Rollbar.error(message)
      Rails.logger.error(message)
      return
    end

    payment.update(donation:) unless payment.donation == donation

    if donation.pending?
      donation.confirm_payment!
      donation.update({ :paid_at => Time.now.utc })

      DonatorBundleAssignmentJob.perform_later(donation.donator_id)

      if donation.gifted?
        NotificationsMailer.donation_received(donation.donator, gifted: true).deliver_later
        NotificationsMailer.gift_sent(donation.donated_by).deliver_later
      else
        NotificationsMailer.donation_received(donation.donator).deliver_later
      end
      # TODO: Notify webhooks
    end
  end
end
