class DonatorBundleAssigner
  def self.assign(...)
    new(...).assign
  end

  def initialize(donator:, bundle:, fund:)
    @donator = donator
    @bundle = bundle
    @fund = fund
  end

  def assign # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    return if fund.blank? || fund.zero?

    complete, partial = donator_bundles.partition(&:complete?)

    self.fund -= bundle.total_value * complete.count

    partial.each do |donator_bundle|
      if (donator_bundle_tier = donator_bundle.next_unlockable_tier).price <= fund
        donator_bundle_tier.unlock!
        self.fund -= donator_bundle_tier.price
      end
    end

    until done?
      donator_bundle = DonatorBundle.create_from(bundle, donator:)

      if (tiers = donator_bundle.unlockable_tiers_at_or_below(fund)).any?
        tiers.each(&:unlock!)
        self.fund -= tiers.last.bundle_tier.price
      end
    end
  end

private

  attr_reader :donator, :bundle
  attr_accessor :fund

  def done?
    fund < bundle.lowest_tier.price || (pro_bono? && donator_bundles.any?(&:complete?))
  end

  def pro_bono?
    bundle.fundraiser.pro_bono?
  end

  def donator_bundles
    donator.donator_bundles.where(bundle:)
  end
end
