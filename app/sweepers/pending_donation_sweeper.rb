class PendingDonationSweeper
  class << self
    def run
      Donation.pending.created_before(1.day.ago).destroy_all
    end
  end
end
