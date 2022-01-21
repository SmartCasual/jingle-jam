require "rails_helper"

RSpec.describe Payment do
  describe ".create_and_assign", queue_type: :test do
    let(:stripe_payment_intent_id) { SecureRandom.uuid }

    context "when a payment already exists with that Stripe ID" do
      let!(:existing_payment) { create(:payment, stripe_payment_intent_id: stripe_payment_intent_id) }

      it "runs the assignment job on the existing payment" do
        described_class.create_and_assign(
          amount: 10_00,
          currency: "gbp",
          stripe_payment_intent_id: stripe_payment_intent_id,
        )
        expect(PaymentAssignmentJob).to have_been_enqueued.with(existing_payment.id)
      end
    end

    context "when a payment already exists with a different Stripe ID" do
      let!(:existing_payment) { create(:payment, stripe_payment_intent_id: "pi_#{SecureRandom.uuid}") }

      it "runs the assignment job on a new payment" do
        described_class.create_and_assign(
          amount: 10_00,
          currency: "gbp",
          stripe_payment_intent_id: stripe_payment_intent_id,
        )
        expect(PaymentAssignmentJob).to have_been_enqueued
        expect(PaymentAssignmentJob).not_to have_been_enqueued.with(existing_payment.id)
      end
    end
  end
end
