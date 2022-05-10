RSpec.describe DonatorBundleTier, type: :model do
  let(:donator_bundle) do
    DonatorBundle.create_from(create(:bundle, :tiered), donator: create(:donator))
  end

  describe "triggering bundle fulfillment" do
    subject(:tier) { donator_bundle.next_unlockable_tier }

    before do
      allow(KeyAssignment::RequestProcessor).to receive(:queue_fulfillment)
    end

    it "triggers fulfillment when the tier is unlocked" do
      tier.unlock!
      expect(KeyAssignment::RequestProcessor).to have_received(:queue_fulfillment).with(tier)
    end

    it "triggers fulfillment when the tier is updated to unlocked" do
      tier.update!(unlocked: true)
      expect(KeyAssignment::RequestProcessor).to have_received(:queue_fulfillment).with(tier)
    end

    it "does not trigger fulfillment when the tier is updated to locked" do
      tier.update!(unlocked: false)
      expect(KeyAssignment::RequestProcessor).not_to have_received(:queue_fulfillment)
    end

    it "triggers fulfillment when the tier is created as unlocked" do
      new_tier = donator_bundle.donator_bundle_tiers.create!(
        unlocked: true,
        bundle_tier: donator_bundle.bundle.bundle_tiers.last,
      )
      expect(KeyAssignment::RequestProcessor).to have_received(:queue_fulfillment).with(new_tier)
    end

    it "does not trigger fulfillment when the tier is created as locked" do
      donator_bundle.donator_bundle_tiers.create!(
        unlocked: false,
        bundle_tier: donator_bundle.bundle.bundle_tiers.last,
      )
      expect(KeyAssignment::RequestProcessor).not_to have_received(:queue_fulfillment)
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

  describe ".unfulfilled" do
    let(:game_1) { create(:game) }
    let(:game_2) { create(:game) }

    let(:bundle_tier) do
      create(:bundle_tier,
        bundle_tier_games: [
          build(:bundle_tier_game, game: game_1),
          build(:bundle_tier_game, game: game_2),
        ],
      )
    end

    let!(:donator_bundle_tier) { create(:donator_bundle_tier, bundle_tier:) }

    context "when a donator bundle tier has no keys assigned" do
      it "returns the donator bundle tier" do
        expect(described_class.unfulfilled).to eq([donator_bundle_tier])
      end
    end

    context "when a donator bundle tier has some keys assigned" do
      before do
        create(:key, game: game_1, donator_bundle_tier:)
      end

      it "returns the donator bundle tier" do
        expect(described_class.unfulfilled).to eq([donator_bundle_tier])
      end
    end

    context "when a donator bundle tier has all keys assigned" do
      before do
        create(:key, game: game_1, donator_bundle_tier:)
        create(:key, game: game_2, donator_bundle_tier:)
      end

      it "does not return the donator bundle tier" do
        expect(described_class.unfulfilled).to be_empty
      end
    end
  end

  describe ".for_fundraiser(fundraiser)" do
    let(:fundraiser) { create(:fundraiser) }

    let(:bundle) { create(:bundle, bundle_tiers: [], fundraiser: bundle_fundraiser) }
    let(:bundle_tier) { create(:bundle_tier, :empty, bundle:) }
    let!(:donator_bundle_tier) { create(:donator_bundle_tier, bundle_tier:) }

    context "when the bundle is associated with the fundraiser" do
      let(:bundle_fundraiser) { fundraiser }

      it "returns the donator bundle tier" do
        expect(described_class.for_fundraiser(fundraiser)).to eq([donator_bundle_tier])
      end
    end

    context "when the bundle is associated with a different fundraiser" do
      let(:bundle_fundraiser) { create(:fundraiser) }

      it "does not return the donator bundle tier" do
        expect(described_class.for_fundraiser(fundraiser)).to be_empty
      end
    end
  end

  describe ".oldest_first" do
    let(:donator_bundle_tier_1) do
      create(:donator_bundle_tier,
        created_at: 1.day.ago,
        updated_at: 1.minute.ago,
      )
    end
    let(:donator_bundle_tier_2) do
      create(:donator_bundle_tier,
        created_at: 2.days.ago,
        updated_at: 20.minutes.ago,
      )
    end
    let(:donator_bundle_tier_3) do
      create(:donator_bundle_tier,
        created_at: 10.seconds.ago,
        updated_at: 10.seconds.ago,
      )
    end

    it "sorts by oldest updated_at and ignores created_at" do
      expect(described_class.oldest_first).to eq(
        [
          donator_bundle_tier_2,
          donator_bundle_tier_1,
          donator_bundle_tier_3,
        ],
      )
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

  describe "#fulfilled?" do
    it "returns true if the donator bundle tier is fulfilled" do
      tier = donator_bundle.donator_bundle_tiers.first
      expect(tier).not_to be_fulfilled

      tier.bundle_tier.games.each do |game|
        tier.keys << build(:key, game:)
      end

      expect(tier).to be_fulfilled
    end
  end
end
