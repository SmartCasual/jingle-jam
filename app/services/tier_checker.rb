class TierChecker
  def donation_level_met?(tier, donator:)
    total_donations = donator.total_donations

    if (full_bundle_price = tier.bundle_definition&.price)
      total_donations >= full_bundle_price || (tier.price.present? && total_donations >= tier.price)
    else
      total_donations >= tier.price
    end
  end
end
