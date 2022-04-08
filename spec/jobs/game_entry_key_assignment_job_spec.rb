require "rails_helper"

RSpec.describe GameEntryKeyAssignmentJob do
  subject(:job) do
    described_class.new(
      key_manager:,
      tier_checker:,
    )
  end

  let(:key_manager) { instance_double("KeyManager") }
  let(:tier_checker) { instance_double("TierChecker") }

  let(:donator) { create(:donator, :with_email_address) }

  let!(:bundle) { create(:bundle, donator:) }
  let(:bundle_id) { bundle.id }

  let!(:game_entry) { create(:bundle_definition_game_entry) }
  let(:game_entry_id) { game_entry.id }

  let(:game) { game_entry.game }

  let!(:admin_users) { create_list(:admin_user, 2) }

  def last_sent_email
    expect(ActionMailer::Base.deliveries).not_to be_empty
    ActionMailer::Base.deliveries.last
  end

  before do
    bundle.donator.donations.create(
      amount_decimals: bundle.bundle_definition.price_decimals,
      amount_currency: bundle.bundle_definition.price_currency,
      stripe_payment_intent_id: "pi_123456789",
    )

    allow(key_manager).to receive(:key_assigned?)
      .and_return(false)
    allow(tier_checker).to receive(:donation_level_met?)
      .and_return(true)
  end

  context "when it gets a lock on an unassigned key" do
    let(:key) { create(:key, game:) }

    before do
      allow(key_manager).to receive(:lock_unassigned_key)
        .with(game).and_yield(key)
    end

    it "assigns the key" do
      job.perform(game_entry_id, bundle_id)
      expect(key.reload.bundle).to eq(bundle)
    end

    it "notifies the donator" do
      job.perform(game_entry_id, bundle_id)
      expect(last_sent_email.to).to eq([donator.email_address])
    end
  end

  context "when it fails to gets a lock on an unassigned key" do
    before do
      allow(key_manager).to receive(:lock_unassigned_key)
        .with(game).and_yield(nil)
    end

    it "does not assign the key" do
      job.perform(game_entry_id, bundle_id)
      expect(bundle.reload.keys).to be_empty
    end

    it "does not notify the donator" do
      job.perform(game_entry_id, bundle_id)
      expect(last_sent_email.to).not_to include(donator.email_address)
    end

    it "notifies the admins" do
      job.perform(game_entry_id, bundle_id)
      expect(last_sent_email.to).to match_array(admin_users.map(&:email))
    end
  end

  context "when there's no bundle" do
    let(:bundle_id) { 7001 }

    it "does nothing" do
      expect_any_instance_of(Key).not_to receive(:update)
      job.perform(game_entry_id, bundle_id)
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  context "when there's no game entry" do
    let(:game_entry_id) { 7001 }

    it "does nothing" do
      expect_any_instance_of(Key).not_to receive(:update)
      job.perform(game_entry_id, bundle_id)
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  context "when there's no game" do
    before do
      game_entry.game.delete
    end

    it "does nothing" do
      expect_any_instance_of(Key).not_to receive(:update)
      job.perform(game_entry_id, bundle_id)
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  context "when there's no donator" do
    before do
      bundle.update(donator: nil)
    end

    it "does nothing" do
      expect_any_instance_of(Key).not_to receive(:update)
      job.perform(game_entry_id, bundle_id)
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  context "when a key has already been assigned" do
    before do
      allow(key_manager).to receive(:key_assigned?)
        .and_return(true)
    end

    it "does nothing" do
      expect_any_instance_of(Key).not_to receive(:update)
      job.perform(game_entry_id, bundle_id)
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  context "when the donation level has not been met" do
    before do
      allow(tier_checker).to receive(:donation_level_met?)
        .and_return(false)
    end

    it "does nothing" do
      expect_any_instance_of(Key).not_to receive(:update)
      job.perform(game_entry_id, bundle_id)
      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end
end
