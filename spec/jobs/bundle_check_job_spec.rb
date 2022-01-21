require "rails_helper"

RSpec.describe BundleCheckJob do
  subject(:job) { described_class.new }

  context "with a donator" do
    let(:donator) { create(:donator) }
    let(:donator_id) { donator.id }

    before do
      allow(Donator).to receive(:find_by).with(id: donator_id)
        .and_return(donator)
      allow(donator).to receive(:assign_keys)
    end

    it "delegates key assignment to the donator" do
      job.perform(donator_id)
      expect(donator).to have_received(:assign_keys)
    end

    it "clears the job" do
      expect {
        job.perform(donator_id)
      }.not_to raise_error
    end
  end

  context "without a donator" do
    let(:donator) { create(:donator) }
    let(:donator_id) { 7001 }

    it "clears the job" do
      expect {
        job.perform(donator_id)
      }.not_to raise_error
    end
  end
end
