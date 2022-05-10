class DonatorBundleAssigner
  def self.assign(...)
    new(...).assign
  end

  def initialize(donator:, bundle:, fund:)
    @donator = donator
    @bundle = bundle
    @fund = fund
  end

  def assign
    return if fund.blank? || fund.zero?

    complete_bundles, partial_bundles = donator_bundles.partition(&:complete?)

    subtract_completed_bundle_value(complete_bundles)
    attempt_to_unlock_partial_bundles(partial_bundles)

    create_bundle_and_apportion_overpayment
  end

private

  attr_reader :donator, :bundle
  attr_accessor :fund

  def subtract_completed_bundle_value(completed_bundles)
    self.fund -= bundle.total_value * completed_bundles.count
  end

  def attempt_to_unlock_partial_bundles(partial_bundles)
    partial_bundles.each do |donator_bundle|
      if (donator_bundle_tier = donator_bundle.next_unlockable_tier).price <= fund
        donator_bundle_tier.unlock!
        self.fund -= donator_bundle_tier.price
      end
    end
  end

  def create_bundle_and_apportion_overpayment
    until done?
      donator_bundle = DonatorBundle.create_from(bundle, donator:)

      if (tiers = donator_bundle.unlockable_tiers_at_or_below(fund)).any?
        tiers.each(&:unlock!)
        self.fund -= tiers.last.bundle_tier.price
      end
    end
  end

  def done?
    (donator_bundles.reload.any? && donator_bundles.none?(&:complete?)) ||
      fund < bundle.lowest_tier.price ||
      (pro_bono? && donator_bundles.any?(&:complete?))
  end

  def pro_bono?
    bundle.fundraiser.pro_bono?
  end

  def donator_bundles
    donator.donator_bundles.where(bundle:)
  end
end
