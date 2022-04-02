require "rails_helper"

RSpec.describe PaymentAssignmentJob, queue_type: :test do
  subject(:job) { described_class.new }

  let(:stripe_payment_intent_id) { "pi_#{SecureRandom.uuid}" }

  let(:payment) do
    create(:payment,
      stripe_payment_intent_id:,
    )
  end
  let!(:donation) do
    create(:donation,
      stripe_payment_intent_id:,
      donator:,
    )
  end

  let(:donator) { create(:donator) }

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
    expect(BundleCheckJob).to have_been_enqueued.with(donator.id)
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

    it "reports the error and does nothing" do
      job.perform(payment_id)
      # TODO: Check for error tracking report

      expect(BundleCheckJob).not_to have_been_enqueued
      expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
    end
  end

  context "if the donation is already linked to the payment" do
    before do
      payment.update(donation:)
    end

    it "remains linked to the payment" do
      job.perform(payment_id)
      expect(payment.reload.donation).to eq(donation)
    end

    it "marks the donation as paid" do
      job.perform(payment_id)
      expect(donation.reload).to be_paid
    end

    it "triggers a bundle check job for the donator" do
      job.perform(payment_id)
      expect(BundleCheckJob).to have_been_enqueued.with(donator.id)
    end

    it "notifies the donator" do
      job.perform(payment_id)
      expect(ActionMailer::MailDeliveryJob).to have_been_enqueued
    end
  end

  context "if the donation is already marked as paid" do
    before do
      donation.confirm_payment!
    end

    it "remains marked as paid" do
      job.perform(payment_id)
      expect(donation.reload).to be_paid
    end

    it "links the payment and the donation" do
      job.perform(payment_id)
      expect(payment.reload.donation).to eq(donation)
    end

    it "does not trigger a bundle check job for the donator" do
      job.perform(payment_id)
      expect(BundleCheckJob).not_to have_been_enqueued
    end

    it "does not notify the donator" do
      job.perform(payment_id)
      expect(ActionMailer::MailDeliveryJob).not_to have_been_enqueued
    end
  end
end
