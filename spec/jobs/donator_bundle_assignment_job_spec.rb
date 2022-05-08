RSpec.describe DonatorBundleAssignmentJob do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(donator_id) }

    let(:inactive_fundraiser) { create(:fundraiser, :inactive) }
    let(:active_fundraiser) { create(:fundraiser, :active) }
    let(:closed_fundraiser) { create(:fundraiser, :active, starts_at: 2.weeks.from_now) }

    let(:donator) { create(:donator) }
    let(:donator_id) { donator.id }

    before do
      [
        inactive_fundraiser,
        active_fundraiser,
        closed_fundraiser,
      ].each do |fundraiser|
        create(:bundle, :live, price: Money.new(10_00, "GBP"), fundraiser:)
        create(:donation, amount: Money.new(10_00, "GBP"), donator:, fundraiser:)
      end

      allow(DonatorBundleAssigner).to receive(:assign).once.and_call_original
    end

    it "assigns bundles only for active fundraisers" do
      expect { perform }.to change { donator.bundles.count }.by(1)
      expect(DonatorBundleAssigner).to have_received(:assign).once
    end

    context "if there's no funds for a fundraiser" do
      before do
        active_fundraiser.donations.destroy_all
      end

      it "does not assign any bundles" do
        perform
        expect(DonatorBundleAssigner).not_to have_received(:assign)
      end
    end

    context "if the bundle is not live" do
      before do
        active_fundraiser.bundles.each(&:retract!)
      end

      it "does not assign any bundles" do
        perform
        expect(DonatorBundleAssigner).not_to have_received(:assign)
      end
    end

    context "if the donator does not exist" do
      let(:donator_id) { 0 }

      it "reports the error" do
        allow(Rollbar).to receive(:error)
        perform
        expect(Rollbar).to have_received(:error).with(
          "Donator not found",
          donator_id:,
        )
      end

      it "does not assign any bundles" do
        perform
        expect(DonatorBundleAssigner).not_to have_received(:assign)
      end
    end
  end
end
