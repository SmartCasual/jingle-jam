class PaymentAssignmentJob < ApplicationJob
  queue_as :default

  def perform(payment_id)
    payment = Payment.find(payment_id)
    donation = Donation.find_by(stripe_payment_intent_id: payment.stripe_payment_intent_id)

    if donation.nil?
      # Notify error tracking
      Rails.logger.info "Missing donation for `#{payment.stripe_payment_intent_id}`"
      return
    end

    payment.update(donation: donation) unless payment.donation == donation

    if donation.pending?
      donation.confirm_payment!

      BundleCheckJob.perform_later(donation.donator_id)
      NotificationsMailer.donation_received(donation.donator).deliver_later
      # TODO: Notify webhooks
    end
  end
end
