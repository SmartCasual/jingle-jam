require "rails_helper"

RSpec.describe TierChecker do
  subject(:tier_checker) { described_class.new }

  describe "#donation_level_met?(tier, donator:)" do
    let(:donator) { create(:donator) }

    let(:bundle_price) { Money.new(2000) }
    let(:tier_price) { Money.new(500) }

    context "with a full bundle" do
      let!(:tier) do
        create(:bundle_definition, price: bundle_price)
      end

      context "with a below-price donation" do
        before do
          create(:donation,
            donator: donator,
            amount: bundle_price - Money.new(1),
          )
        end

        it "returns false" do
          expect(tier_checker.donation_level_met?(tier, donator: donator)).to eq(false)
        end
      end

      context "with an at-price donation" do
        before do
          create(:donation,
            donator: donator,
            amount: bundle_price,
          )
        end

        it "returns true" do
          expect(tier_checker.donation_level_met?(tier, donator: donator)).to eq(true)
        end
      end

      context "with an above-price donation" do
        before do
          create(:donation,
            donator: donator,
            amount: bundle_price + Money.new(1),
          )
        end

        it "returns true" do
          expect(tier_checker.donation_level_met?(tier, donator: donator)).to eq(true)
        end
      end
    end

    context "with a bundle tier with a price" do
      let!(:tier) do
        bundle_definition = create(:bundle_definition, price: bundle_price)
        create(:bundle_definition_game_entry, price: tier_price, bundle_definition: bundle_definition)
      end

      context "with a below-tier donation" do
        before do
          create(:donation,
            donator: donator,
            amount: tier_price - Money.new(1),
          )
        end

        it "returns false" do
          expect(tier_checker.donation_level_met?(tier, donator: donator)).to eq(false)
        end
      end

      context "with an at-tier donation" do
        before do
          create(:donation,
            donator: donator,
            amount: tier_price,
          )
        end

        it "returns true" do
          expect(tier_checker.donation_level_met?(tier, donator: donator)).to eq(true)
        end
      end

      context "with an above-tier donation" do
        before do
          create(:donation,
            donator: donator,
            amount: tier_price + Money.new(1),
          )
        end

        it "returns true" do
          expect(tier_checker.donation_level_met?(tier, donator: donator)).to eq(true)
        end
      end
    end

    context "with a bundle tier without a price" do
      let!(:tier) do
        bundle_definition = create(:bundle_definition, price: bundle_price)
        create(:bundle_definition_game_entry, price: nil, bundle_definition: bundle_definition)
      end

      context "with a below-bundle donation" do
        before do
          create(:donation,
            donator: donator,
            amount: bundle_price - Money.new(1),
          )
        end

        it "returns false" do
          expect(tier_checker.donation_level_met?(tier, donator: donator)).to eq(false)
        end
      end

      context "with an at-bundle donation" do
        before do
          create(:donation,
            donator: donator,
            amount: bundle_price,
          )
        end

        it "returns true" do
          expect(tier_checker.donation_level_met?(tier, donator: donator)).to eq(true)
        end
      end

      context "with an above-bundle donation" do
        before do
          create(:donation,
            donator: donator,
            amount: bundle_price + Money.new(1),
          )
        end

        it "returns true" do
          expect(tier_checker.donation_level_met?(tier, donator: donator)).to eq(true)
        end
      end
    end
  end
end
