require "rails_helper"

RSpec.describe PaymentAssignmentJob, queue_type: :test do
  subject(:job) { described_class.new }

  let(:stripe_payment_intent_id) { "pi_#{SecureRandom.uuid}" }

  let(:payment) do
    FactoryBot.create(:payment,
      stripe_payment_intent_id: stripe_payment_intent_id,
    )
  end
  let!(:donation) do
    FactoryBot.create(:donation,
      stripe_payment_intent_id: stripe_payment_intent_id,
    )
  end

  let(:payment_id) { payment.id }

  it "links the payment and the donation" do
    job.perform(payment_id)
    expect(payment.reload.donation).to eq(donation)
  end

  it "marks the donation as paid" do
    job.perform(payment_id)
    expect(donation.reload).to be_paid
  end

  it "triggers a bundle check job for the donator" do
    job.perform(payment_id)
    expect(BundleCheckJob).to have_been_enqueued
  end

  it "notifies the donator" do
    job.perform(payment_id)
    expect(ActionMailer::MailDeliveryJob).to have_been_enqueued
  end

  context "if the payment isn't found" do
    let(:payment_id) { 1234 }

    it "errors and does nothing" do
      expect {
        job.perform(payment_id)
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect(BundleCheckJob).not_to have_been_enqueued
      expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
    end
  end

  context "if the donation isn't found" do
    before do
      Donation.destroy_all
    end

    it "errors and does nothing" do
      expect {
        job.perform(payment_id)
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect(BundleCheckJob).not_to have_been_enqueued
      expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
    end
  end
end
