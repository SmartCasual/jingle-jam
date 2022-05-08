RSpec.describe DonatorBundleTier, type: :model do
  let(:donator_bundle) do
    DonatorBundle.create_from(create(:bundle, :tiered), donator: create(:donator))
  end

  describe "triggering bundle fulfillment" do
    subject(:tier) { donator_bundle.next_unlockable_tier }

    before do
      allow(DonatorBundleTierFulfillmentJob).to receive(:perform_later)
    end

    it "triggers fulfillment when the tier is unlocked" do
      tier.unlock!
      expect(DonatorBundleTierFulfillmentJob).to have_received(:perform_later).with(tier.id)
    end

    it "triggers fulfillment when the tier is updated to unlocked" do
      tier.update!(unlocked: true)
      expect(DonatorBundleTierFulfillmentJob).to have_received(:perform_later).with(tier.id)
    end

    it "does not trigger fulfillment when the tier is updated to locked" do
      tier.update!(unlocked: false)
      expect(DonatorBundleTierFulfillmentJob).not_to have_received(:perform_later)
    end

    it "triggers fulfillment when the tier is created as unlocked" do
      new_tier = donator_bundle.donator_bundle_tiers.create!(
        unlocked: true,
        bundle_tier: donator_bundle.bundle.bundle_tiers.last,
      )
      expect(DonatorBundleTierFulfillmentJob).to have_received(:perform_later).with(new_tier.id)
    end

    it "does not trigger fulfillment when the tier is created as locked" do
      donator_bundle.donator_bundle_tiers.create!(
        unlocked: false,
        bundle_tier: donator_bundle.bundle.bundle_tiers.last,
      )
      expect(DonatorBundleTierFulfillmentJob).not_to have_received(:perform_later)
    end
  end

  describe ".locked" do
    it "returns the locked donator bundle tiers" do
      tiers = donator_bundle.donator_bundle_tiers.to_a
      expect(tiers.count).to be_positive

      tiers.pop.unlock!
      expect(described_class.locked).to match_array(tiers)
    end
  end

  describe "#unlock!" do
    it "unlocks the donator bundle tier" do
      tier = donator_bundle.donator_bundle_tiers.first
      expect(tier).to be_locked

      tier.unlock!
      expect(tier).to be_unlocked
    end

    context "when the donator bundle tier is already unlocked" do
      before do
        donator_bundle.donator_bundle_tiers.first.unlock!
      end

      it "does nothing" do
        tier = donator_bundle.donator_bundle_tiers.first
        expect(tier).to be_unlocked

        allow(tier).to receive(:update!).and_call_original

        tier.unlock!
        expect(tier).to be_unlocked
        expect(tier).not_to have_received(:update!)
      end
    end
  end

  describe "#locked?" do
    it "returns true if the donator bundle tier is locked" do
      tier = donator_bundle.donator_bundle_tiers.first
      expect(tier).to be_locked
      tier.unlock!
      expect(tier).not_to be_locked
    end
  end
end
