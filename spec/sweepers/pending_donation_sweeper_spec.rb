require "rails_helper"

RSpec.describe PendingDonationSweeper do
  subject(:sweeper) { described_class }

  describe "#run" do
    it "deletes pending donations older than 24 hours" do
      new_pending = FactoryBot.create(:donation, created_at: 1.hour.ago)
      old_pending = FactoryBot.create(:donation, created_at: 2.days.ago)

      sweeper.run

      expect(Donation).to exist(id: new_pending.id)
      expect(Donation).not_to exist(id: old_pending.id)
    end

    it "does not delete non-pending donations of any age" do
      donations = []

      donations << FactoryBot.create(:donation, :paid, created_at: 1.hour.ago)
      donations << FactoryBot.create(:donation, :paid, created_at: 2.days.ago)

      donations << FactoryBot.create(:donation, :cancelled, created_at: 1.hour.ago)
      donations << FactoryBot.create(:donation, :cancelled, created_at: 2.days.ago)

      donations << FactoryBot.create(:donation, :fulfilled, created_at: 1.hour.ago)
      donations << FactoryBot.create(:donation, :fulfilled, created_at: 2.days.ago)

      donations.each do |donation|
        expect(Donation).to exist(id: donation.id)
      end
    end
  end
end
