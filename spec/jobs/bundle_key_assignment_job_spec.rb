require "rails_helper"

RSpec.describe BundleKeyAssignmentJob do
  subject(:job) { described_class.new }

  context "with a bundle" do
    let(:bundle) { create(:bundle) }
    let(:bundle_id) { bundle.id }

    before do
      allow(Bundle).to receive(:find_by).with(id: bundle_id)
        .and_return(bundle)
      allow(bundle).to receive(:assign_keys)
    end

    it "delegates key assignment to the bundle" do
      job.perform(bundle_id)
      expect(bundle).to have_received(:assign_keys)
    end

    it "clears the job" do
      expect {
        job.perform(bundle_id)
      }.not_to raise_error
    end
  end

  context "without a bundle" do
    let(:bundle) { create(:bundle) }
    let(:bundle_id) { 7001 }

    it "clears the job" do
      expect {
        job.perform(bundle_id)
      }.not_to raise_error
    end
  end
end
