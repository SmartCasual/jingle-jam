require "rails_helper"

RSpec.describe Bundle, type: :model do
  subject(:bundle) { create(:bundle, bundle_definition:) }

  let(:bundle_definition) do
    create(:bundle_definition, :draft,
      bundle_definition_game_entries: [bundle_definition_game_entry],
    )
  end

  let(:bundle_definition_game_entry) { create(:bundle_definition_game_entry) }

  describe "#assign_keys" do
    before do
      allow(GameEntryKeyAssignmentJob).to receive(:perform_later)
    end

    context "with a draft bundle definition" do
      it "does not assign keys" do
        bundle.assign_keys
        expect(GameEntryKeyAssignmentJob).not_to have_received(:perform_later)
      end
    end

    context "with a live bundle definition" do
      before do
        bundle_definition.publish!
      end

      it "assigns keys to the associated game entries" do
        bundle.assign_keys
        expect(GameEntryKeyAssignmentJob).to have_received(:perform_later)
          .with(bundle_definition_game_entry.id, bundle.id)
      end
    end
  end
end
