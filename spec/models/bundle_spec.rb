require "rails_helper"

RSpec.describe Bundle, type: :model do
  subject(:bundle) do
    described_class.new(
      attrs.merge(
        fundraiser:,
        name: "Some bundle",
      ),
    )
  end

  let(:attrs) { {} }
  let(:fundraiser) { create(:fundraiser, main_currency: "GBP") }

  describe "state machine" do
    it { is_expected.to have_state(:draft) }
    it { is_expected.to transition_from(:draft).to(:live).on_event(:publish) }
    it { is_expected.to transition_from(:live).to(:draft).on_event(:retract) }
  end

  describe "#highest_tier" do
    context "if there's no tiers" do
      it "returns nil" do
        expect(bundle.highest_tier).to be_nil
      end
    end

    context "if there's tiers" do
      let(:attrs) { { bundle_tiers: [lowest_tier, highest_tier] } }

      let(:lowest_tier) { create(:bundle_tier, price: Money.new(1_00, "GBP")) }
      let(:highest_tier) { create(:bundle_tier, price: Money.new(10_00, "GBP")) }

      it "returns the highest tier" do
        expect(bundle.highest_tier).to eq(highest_tier)
      end
    end
  end

  describe "#lowest_tier" do
    context "if there's no tiers" do
      it "returns nil" do
        expect(bundle.highest_tier).to be_nil
      end
    end

    context "if there's tiers" do
      let(:attrs) { { bundle_tiers: [lowest_tier, highest_tier] } }

      let(:lowest_tier) { create(:bundle_tier, price: Money.new(1_00, "GBP")) }
      let(:highest_tier) { create(:bundle_tier, price: Money.new(10_00, "GBP")) }

      it "returns the lowest tier" do
        expect(bundle.lowest_tier).to eq(lowest_tier)
      end
    end
  end

  describe "tier currency validation" do
    let(:attrs) { { bundle_tiers: [gbp_tier, tier] } }

    let(:gbp_tier) { build(:bundle_tier, price: Money.new(1_00, "GBP")) }
    let(:tier) { build(:bundle_tier) }

    it "is valid if the tiers are all in the same currency" do
      tier.price = Money.new(1_00, "GBP")
      expect(bundle).to be_valid
    end

    it "is invalid if the tiers are in different currencies" do
      tier.price = Money.new(1_00, "EUR")
      expect(bundle).not_to be_valid
    end
  end

  describe "#currency" do
    context "if the bundle has no tiers" do
      it "returns nil" do
        expect(bundle.currency).to be_nil
      end
    end

    context "if the bundle has tiers" do
      let(:attrs) { { bundle_tiers: [tier] } }

      let(:tier) { build(:bundle_tier, price: Money.new(1_00, "GBP")) }

      it "returns the currency of the highest tier" do
        expect(bundle.currency).to eq("GBP")
      end
    end
  end
end
