RSpec.describe KeyAssignment::KeyManager do
  subject(:key_manager) { described_class.new }

  let(:game) { create(:game) }
  let(:donator_bundle_tier) { create(:donator_bundle_tier) }

  describe "#key_assigned?(game, donator_bundle_tier:)" do
    context "when the donator_bundle_tier has a key for the game" do
      before do
        create(:key, game:, donator_bundle_tier:)
      end

      it "returns true" do
        expect(key_manager.key_assigned?(game, donator_bundle_tier:)).to be(true)
      end
    end

    context "when the donator_bundle_tier does not have a key for the game" do
      before do
        create(:key, game:, donator_bundle_tier: nil)
      end

      it "returns true" do
        expect(key_manager.key_assigned?(game, donator_bundle_tier:)).to be(false)
      end
    end
  end

  describe "#lock_unassigned_key(game, fundraiser: nil)" do
    subject(:lock) { key_manager.lock_unassigned_key(game) }

    before do
      allow(Key).to receive(:transaction)
    end

    context "when there's no unassigned keys for the game" do
      before do
        create(:key, game:, donator_bundle_tier:)
        create(:key)
      end

      it "opens a transaction" do
        lock
        expect(Key).to have_received(:transaction)
      end

      it "yields nothing" do
        lock do |key|
          expect(key).to be_nil
        end
      end
    end

    context "when there are unassigned keys for the game" do
      let!(:unassigned_key) { create(:key, game:, donator_bundle_tier: nil) }

      it "opens a transaction" do
        lock
        expect(Key).to have_received(:transaction)
      end

      it "yields an unassigned key" do
        lock do |key|
          expect(key).to eq(unassigned_key)
        end
      end
    end

    context "if a fundraiser is specified" do
      subject(:lock) do
        key_manager.lock_unassigned_key(game, fundraiser:)
      end

      let(:fundraiser) { create(:fundraiser) }

      context "and there is a key available for the fundraiser" do
        let!(:fundraiser_key) { create(:key, game:, fundraiser:) }

        it "yields the fundraiser key" do
          lock do |key|
            expect(key).to eq(fundraiser_key)
          end
        end
      end

      context "and there isn't a fundraiser-specific key but there is a generic key" do
        let!(:generic_key) { create(:key, game:, fundraiser: nil) }

        it "yields the generic key" do
          lock do |key|
            expect(key).to eq(generic_key)
          end
        end
      end

      context "and there isn't a fundraiser-specific or generic key" do
        it "yields nothing" do
          lock do |key|
            expect(key).to be_nil
          end
        end
      end

      context "and there isn't a key for that fundraiser but there is a key for another fundraiser" do
        before { create(:key, game:, fundraiser: create(:fundraiser)) }

        it "yields nothing" do
          lock do |key|
            expect(key).to be_nil
          end
        end
      end
    end
  end
end
