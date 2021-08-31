module DonationHelpers
  def new_donation(amount, streamer)
    Donation.new(amount: amount, curated_streamer: streamer).tap do |donation|
      if donation.charity_splits.none?
        Charity.find_each do |charity|
          donation.charity_splits.build(charity: charity)
        end
      end
    end
  end
end
