RSpec.describe DonatorBundle, type: :model do
  let(:bundle) { create(:bundle, bundle_tiers:) }

  let(:top_tier_price) { Money.new(20_00, "GBP") }
  let(:middle_tier_price) { Money.new(10_00, "GBP") }
  let(:bottom_tier_price) { Money.new(5_00, "GBP") }

  let(:bundle_tiers) do
    [
      build(:bundle_tier, price: top_tier_price),
      build(:bundle_tier, price: middle_tier_price),
      build(:bundle_tier, price: bottom_tier_price),
    ]
  end

  let(:donator) { create(:donator) }

  let(:donator_bundle) do
    described_class.create_from(bundle, donator:)
  end

  describe ".build_from(bundle)" do
    subject(:result) { described_class.build_from(bundle, donator:) }

    it { is_expected.to be_a(described_class) }

    it "sets the donator" do
      expect(result.donator).to eq(donator)
    end

    it "sets the donator bundle tiers" do
      expect(result.donator_bundle_tiers.map(&:bundle_tier)).to match_array(bundle_tiers)
    end

    it "defaults the donator bundle tiers to locked" do
      expect(result.donator_bundle_tiers.map(&:unlocked).uniq).to eq([false])
    end

    it { is_expected.to be_new_record }
  end

  describe ".create_from(bundle)" do
    subject(:result) { described_class.create_from(bundle, donator:) }

    it { is_expected.to be_a(described_class) }

    it "sets the donator bundle tiers" do
      expect(result.donator_bundle_tiers.map(&:bundle_tier)).to match_array(bundle_tiers)
    end

    it "defaults the donator bundle tiers to locked" do
      expect(result.donator_bundle_tiers.map(&:unlocked).uniq).to eq([false])
    end

    it { is_expected.to be_persisted }
  end

  describe "#complete?" do
    subject { donator_bundle.complete? }

    context "when no donator bundle tiers are unlocked" do
      it { is_expected.to be(false) }
    end

    context "when some donator bundle tiers are unlocked" do
      before do
        donator_bundle.donator_bundle_tiers.first.unlock!
      end

      it { is_expected.to be(false) }
    end

    context "when all donator bundle tiers are unlocked" do
      before do
        donator_bundle.donator_bundle_tiers.each(&:unlock!)
      end

      it { is_expected.to be(true) }
    end
  end

  describe "#next_unlockable_tier" do
    subject(:result) { donator_bundle.next_unlockable_tier }

    let(:tiers) { donator_bundle.donator_bundle_tiers }

    let(:top_bundle_tier) { tiers.find { |t| t.bundle_tier.price == top_tier_price } }
    let(:middle_bundle_tier) { tiers.find { |t| t.bundle_tier.price == middle_tier_price } }
    let(:bottom_bundle_tier) { tiers.find { |t| t.bundle_tier.price == bottom_tier_price } }

    context "when no donator bundle tiers are unlocked" do
      it "returns the lowest donator bundle tier" do
        expect(result).to eq(bottom_bundle_tier)
      end
    end

    context "when some donator bundle tiers are unlocked" do
      before do
        bottom_bundle_tier.unlock!
      end

      it "returns the next lowest donator bundle tier" do
        expect(result).to eq(middle_bundle_tier)
      end
    end

    context "when some donator bundle tiers are unlocked but the rest are out of date" do
      before do
        bottom_bundle_tier.unlock!
        middle_bundle_tier.bundle_tier.update(starts_at: 1.week.from_now)
        top_bundle_tier.bundle_tier.update(ends_at: 1.week.ago)
      end

      it { is_expected.to be_nil }
    end

    context "when all donator bundle tiers are unlocked" do
      before do
        donator_bundle.donator_bundle_tiers.each(&:unlock!)
      end

      it { is_expected.to be_nil }
    end
  end

  describe "#unlockable_tiers_at_or_below(amount)" do
    let(:top_bundle_tier) { donator_bundle.donator_bundle_tiers.find { |t| t.bundle_tier.price == top_tier_price } }
    let(:middle_bundle_tier) {
      donator_bundle.donator_bundle_tiers.find { |t|
        t.bundle_tier.price == middle_tier_price
      }
    }
    let(:bottom_bundle_tier) {
      donator_bundle.donator_bundle_tiers.find { |t|
        t.bundle_tier.price == bottom_tier_price
      }
    }

    it "returns the unlockable tiers at or below the amount" do
      bottom_bundle_tier.unlock!
      result = donator_bundle.unlockable_tiers_at_or_below(top_tier_price)
      expect(result).to match_array([middle_bundle_tier, top_bundle_tier])
    end
  end
end
