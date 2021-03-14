require "rails_helper"

RSpec.describe KeyManager do
  subject(:key_manager) { described_class.new }

  let(:game) { FactoryBot.create(:game) }
  let(:bundle) { FactoryBot.create(:bundle) }

  describe "#key_assigned?(game, bundle:)" do
    context "when the bundle has a key for the game" do
      before do
        FactoryBot.create(:key, game: game, bundle: bundle)
      end

      it "returns true" do
        expect(key_manager.key_assigned?(game, bundle: bundle)).to eq(true)
      end
    end

    context "when the bundle does not have a key for the game" do
      before do
        FactoryBot.create(:key, game: game, bundle: nil)
      end

      it "returns true" do
        expect(key_manager.key_assigned?(game, bundle: bundle)).to eq(false)
      end
    end
  end

  describe "#lock_unassigned_key(game)" do
    context "when there's no unassigned keys for the game" do
      before do
        FactoryBot.create(:key, game: game, bundle: bundle)
        FactoryBot.create(:key)
      end

      it "opens a transaction" do
        expect(Key).to receive(:transaction)
        key_manager.lock_unassigned_key(game)
      end

      it "yields nothing" do
        key_manager.lock_unassigned_key(game) do |key|
          expect(key).to be_nil
        end
      end
    end
  end

  describe "#lock_unassigned_key(game)" do
    context "when there are unassigned keys for the game" do
      let!(:unassigned_key) { FactoryBot.create(:key, game: game, bundle: nil) }

      it "opens a transaction" do
        expect(Key).to receive(:transaction)
        key_manager.lock_unassigned_key(game)
      end

      it "yields an unassigned key" do
        key_manager.lock_unassigned_key(game) do |key|
          expect(key).to eq(unassigned_key)
        end
      end
    end
  end
end
