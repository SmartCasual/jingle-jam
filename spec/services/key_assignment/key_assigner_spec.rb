RSpec.describe KeyAssignment::KeyAssigner do
  subject(:service) { described_class.new(key_manager:) }

  let(:key_manager) { instance_double(KeyAssignment::KeyManager) }

  let(:donator) { create(:donator, :with_email_address, :confirmed) }
  let(:donator_bundle) { create(:donator_bundle, donator:) }
  let(:donator_bundle_tier) { create(:donator_bundle_tier, donator_bundle:, unlocked: true) }

  let(:game) { donator_bundle_tier.bundle_tier.games.first }

  let!(:admin_users) { create_list(:admin_user, 2) }

  let(:bundle_assigned_emails) { ActionMailer::Base.deliveries.select { |mail| mail.subject == "Bundle assigned" } }

  def last_sent_email
    expect(ActionMailer::Base.deliveries).not_to be_empty
    ActionMailer::Base.deliveries.last
  end

  before do
    allow(key_manager).to receive(:key_assigned?)
      .and_return(false)

    allow_any_instance_of(DonatorBundleTier).to receive(:trigger_fulfillment)
  end

  context "when it gets a lock on an unassigned key" do
    let(:key) { create(:key, game:) }

    before do
      allow(key_manager).to receive(:lock_unassigned_key)
        .with(game, fundraiser: anything).and_yield(key)
    end

    it "assigns the key" do
      service.assign(donator_bundle_tier)
      expect(key.reload.donator_bundle_tier).to eq(donator_bundle_tier)
    end

    it "notifies the donator" do
      service.assign(donator_bundle_tier)
      expect(last_sent_email.to).to eq([donator.email_address])
    end

    context "but the donator does not have an email address" do
      before do
        donator.update(email_address: nil)
        donator.confirm
      end

      it "assigns the keys" do
        service.assign(donator_bundle_tier)
        expect(donator_bundle_tier.reload.keys).not_to be_empty
      end

      it "does not email the donator" do
        service.assign(donator_bundle_tier)
        expect(bundle_assigned_emails).to be_empty
      end
    end

    context "but the donator has a blank email address" do
      before do
        donator.update(email_address: "")
        donator.confirm
      end

      it "assigns the keys" do
        service.assign(donator_bundle_tier)
        expect(donator_bundle_tier.reload.keys).not_to be_empty
      end

      it "does not email the donator" do
        service.assign(donator_bundle_tier)
        expect(bundle_assigned_emails).to be_empty
      end
    end

    context "but the donator's email address is unconfirmed" do
      before do
        donator.update(confirmed_at: nil)
      end

      it "assigns the keys" do
        service.assign(donator_bundle_tier)
        expect(donator_bundle_tier.reload.keys).not_to be_empty
      end

      it "does not email the donator" do
        service.assign(donator_bundle_tier)
        expect(bundle_assigned_emails).to be_empty
      end
    end
  end

  context "when it fails to gets a lock on an unassigned key" do
    before do
      allow(key_manager).to receive(:lock_unassigned_key)
        .with(game, fundraiser: anything).and_yield(nil)
    end

    it "does not assign the key" do
      service.assign(donator_bundle_tier)
      expect(donator_bundle_tier.reload.keys).to be_empty
    end

    it "does not notify the donator" do
      service.assign(donator_bundle_tier)
      expect(last_sent_email.to).not_to include(donator.email_address)
    end

    it "notifies the admins" do
      service.assign(donator_bundle_tier)
      expect(last_sent_email.to).to match_array(admin_users.map(&:email_address))
    end
  end

  context "when there's no donator bundle tier" do
    let(:donator_bundle_tier) { nil }

    it "does nothing" do
      service.assign(donator_bundle_tier)
      expect(bundle_assigned_emails).to be_empty
    end
  end

  context "when the donator bundle tier is locked" do
    before do
      donator_bundle_tier.update(unlocked: false)
    end

    it "does nothing" do
      service.assign(donator_bundle_tier)
      expect(donator_bundle_tier.reload.keys).to be_empty
      expect(bundle_assigned_emails).to be_empty
    end
  end

  context "when there's no game" do
    before do
      donator_bundle_tier.bundle_tier.games.destroy_all
    end

    it "does nothing" do
      service.assign(donator_bundle_tier)
      expect(donator_bundle_tier.reload.keys).to be_empty
      expect(bundle_assigned_emails).to be_empty
    end
  end

  context "when a key has already been assigned" do
    before do
      allow(key_manager).to receive(:key_assigned?)
        .and_return(true)
    end

    it "does nothing" do
      service.assign(donator_bundle_tier)
      expect(donator_bundle_tier.reload.keys).to be_empty
      expect(bundle_assigned_emails).to be_empty
    end
  end
end
