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
      # Notify error tracking
      Rails.logger.info "Missing donation for `#{payment.stripe_payment_intent_id}`"
      return
    end

    payment.update(donation:) unless payment.donation == donation

    if donation.pending?
      donation.confirm_payment!

      DonatorBundleAssignmentJob.perform_later(donation.donator_id)
      NotificationsMailer.donation_received(donation.donator).deliver_later
      # TODO: Notify webhooks
    end
  end
end
