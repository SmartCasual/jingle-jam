class TierChecker
  def donation_level_met?(tier, donator:)
    total_donations = donator.total_donations

    if tier.respond_to?(:bundle_definition)
      total_donations >= tier.bundle_definition.price || (tier.price.present? && total_donations >= tier.price)
    else
      total_donations >= tier.price
    end
  end
end
