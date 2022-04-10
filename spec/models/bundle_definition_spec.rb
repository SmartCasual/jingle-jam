require "rails_helper"

RSpec.describe BundleDefinition, type: :model do
  subject(:bundef) { described_class.new }

  describe "state machine" do
    it { is_expected.to have_state(:draft) }
    it { is_expected.to transition_from(:draft).to(:live).on_event(:publish) }
    it { is_expected.to transition_from(:live).to(:draft).on_event(:retract) }
  end

  describe "#update_assignments(force: false)" do
    before do
      allow(BundleKeyAssignmentJob).to receive(:perform_later)
    end

    context "when bundle definition is draft" do
      let(:bundle) { create(:bundle) }
      let(:bundle_definition) { bundle.bundle_definition }

      context "when forced" do
        it "updates the bundle key assignments" do
          expect(BundleKeyAssignmentJob).to receive(:perform_later).with(bundle.id)
          bundle_definition.update_assignments(force: true)
        end
      end

      context "when not forced" do
        it "does not update the bundle key assignments" do
          expect(BundleKeyAssignmentJob).not_to receive(:perform_later)
          bundle_definition.update_assignments
        end
      end
    end

    context "when bundle definition is live" do
      let(:bundle) { create(:bundle) }
      let(:bundle_definition) { bundle.bundle_definition }

      before { bundle_definition.publish! }

      it "updates the bundle key assignments" do
        expect(BundleKeyAssignmentJob).to receive(:perform_later).with(bundle.id)
        bundle_definition.update_assignments
      end
    end
  end
end
