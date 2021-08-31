# TODO: Unit test this
class PaymentAssignmentJob < ApplicationJob
  queue_as :default

  def perform(payment_id)
    payment = Payment.find(payment_id)
    donation = Donation.find_by!(stripe_payment_intent_id: payment.stripe_payment_intent_id)

    payment.update(donation: donation)
    donation.confirm_payment!

    BundleCheckJob.perform_later(donation.donator_id)
    NotificationsMailer.donation_received(donation.donator).deliver_later
    # TODO: Notify webhooks
  end
end
