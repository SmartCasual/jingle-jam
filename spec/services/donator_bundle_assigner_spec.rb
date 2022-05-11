RSpec.describe DonatorBundleAssigner do
  describe ".assign(donator:, bundle:, fund:)" do
    subject(:assignment) do
      described_class.assign(donator:, bundle:, fund:)
    end

    let(:donator) { create(:donator) }
    let(:bundle) { create(:bundle, bundle_tiers:) }
    let(:fund) { nil }

    let(:bundle_tiers) do
      [
        build(:bundle_tier, price: top_tier_price),
        build(:bundle_tier, price: middle_tier_price),
        build(:bundle_tier, price: bottom_tier_price),
      ]
    end

    let(:top_tier_price) { Money.new(20_00, "GBP") }
    let(:middle_tier_price) { Money.new(10_00, "GBP") }
    let(:bottom_tier_price) { Money.new(5_00, "GBP") }

    let(:donator_bundle) { donator.donator_bundles.last }

    context "when the donations are enough for part of the bundle" do
      let(:fund) { middle_tier_price }

      it "creates a donator bundle" do
        expect { assignment }.to change(donator.reload.donator_bundles, :count).by(1)
      end

      it "unlocks the paid-for tiers" do
        assignment
        unlocked_tier_prices = donator_bundle.donator_bundle_tiers.unlocked.map(&:price)
        expect(unlocked_tier_prices).to match_array([bottom_tier_price, middle_tier_price])
      end

      context "and the bundle is already assigned" do
        let(:existing_donator_bundle) { DonatorBundle.create_from(bundle, donator:) }

        before do
          existing_donator_bundle.next_unlockable_tier.unlock!
        end

        it "doesn't create a donator bundle" do
          expect { assignment }.not_to change(donator.reload.donator_bundles, :count)
        end

        it "unlocks any relevant locked tiers" do
          assignment
          unlocked_tier_prices = existing_donator_bundle.donator_bundle_tiers.unlocked.map(&:price)
          expect(unlocked_tier_prices).to match_array([bottom_tier_price, middle_tier_price])
        end
      end
    end

    context "when the donations are enough for the whole bundle" do
      let(:fund) { top_tier_price }

      it "creates a donator bundle" do
        expect { assignment }.to change(donator.reload.donator_bundles, :count).by(1)
      end

      it "unlocks all the tiers" do
        assignment
        expect(donator_bundle).to be_complete
      end
    end

    context "when there's a little bit more than enough for the whole bundle" do
      let(:fund) { top_tier_price + Money.new(1_00, "GBP") }

      context "and the fundraiser is in pro bono mode" do
        before do
          bundle.fundraiser.update(overpayment_mode: Fundraiser::PRO_BONO)
        end

        it "only creates 1 donator bundle" do
          expect { assignment }.to change(donator.reload.donator_bundles, :count).by(1)
        end
      end

      context "and the fundraiser is in pro se mode" do
        before do
          bundle.fundraiser.update(overpayment_mode: Fundraiser::PRO_SE)
        end

        it "still only creates 1 donator bundle" do
          expect { assignment }.to change(donator.reload.donator_bundles, :count).by(1)
        end
      end
    end

    context "when there's enough extra for a tier on another bundle" do
      let(:fund) { top_tier_price + bottom_tier_price }

      context "and the fundraiser is in pro bono mode" do
        before do
          bundle.fundraiser.update(overpayment_mode: Fundraiser::PRO_BONO)
        end

        it "only creates 1 donator bundle" do
          expect { assignment }.to change(donator.reload.donator_bundles, :count).by(1)
        end

        it "fully unlocks the bundle" do
          assignment
          expect(donator.donator_bundles.order(:id).first).to be_complete
        end
      end

      context "and the fundraiser is in pro se mode" do
        before do
          bundle.fundraiser.update(overpayment_mode: Fundraiser::PRO_SE)
        end

        it "creates 2 donator bundles" do
          expect { assignment }.to change(donator.reload.donator_bundles, :count).by(2)
        end

        it "fully unlocks the first bundle" do
          assignment
          expect(donator.donator_bundles.order(:id).first).to be_complete
        end

        it "partially unlocks the second bundle" do
          assignment
          unlocked_tier_prices = donator
            .donator_bundles.order(:id).second
            .donator_bundle_tiers.unlocked.map(&:price)
          expect(unlocked_tier_prices).to match_array([bottom_tier_price])
        end

        context "but the bundle cannot be fully unlocked" do
          before do
            bundle.highest_tier.update(starts_at: 2.days.from_now)
          end

          it "only creates 1 donator bundle" do
            expect { assignment }.to change(donator.reload.donator_bundles, :count).by(1)
          end

          it "does not fully unlock the bundle" do
            assignment
            expect(donator.donator_bundles.order(:id).first).not_to be_complete
          end
        end
      end
    end
  end
end
