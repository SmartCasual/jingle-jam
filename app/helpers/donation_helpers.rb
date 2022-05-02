module DonationHelpers
  def new_donation(amount, fundraiser:)
    Donation.new(amount:).tap do |donation|
      if donation.charity_splits.none?
        fundraiser.charities.find_each do |charity|
          donation.charity_splits.build(charity:)
        end
      end
    end
  end
end
