class TierChecker
  def donation_level_met?(tier, donator:)
    total_donations = donator.total_donations(fundraiser: tier.bundle_definition.fundraiser)

    (total_donations >= tier.bundle_definition.price) || (tier.price.present? && total_donations >= tier.price)
  end
end
