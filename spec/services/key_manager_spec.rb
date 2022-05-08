RSpec.describe KeyManager do
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

  describe "#lock_unassigned_key(game)" do
    before do
      allow(Key).to receive(:transaction)
    end

    context "when there's no unassigned keys for the game" do
      before do
        create(:key, game:, donator_bundle_tier:)
        create(:key)
      end

      it "opens a transaction" do
        key_manager.lock_unassigned_key(game)
        expect(Key).to have_received(:transaction)
      end

      it "yields nothing" do
        key_manager.lock_unassigned_key(game) do |key|
          expect(key).to be_nil
        end
      end
    end

    context "when there are unassigned keys for the game" do
      let!(:unassigned_key) { create(:key, game:, donator_bundle_tier: nil) }

      it "opens a transaction" do
        key_manager.lock_unassigned_key(game)
        expect(Key).to have_received(:transaction)
      end

      it "yields an unassigned key" do
        key_manager.lock_unassigned_key(game) do |key|
          expect(key).to eq(unassigned_key)
        end
      end
    end
  end
end
