class DonatorBundleAssigner
  def self.assign(...)
    new(...).assign
  end

  def initialize(donator:, bundle:, fund:)
    @donator = donator
    @bundle = bundle
    @fund = fund.exchange_to(bundle.currency)
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

  # FIXME: Reduce the cyclomatic complexity of this method.
  def create_bundle_and_apportion_overpayment # rubocop:disable Metrics/CyclomaticComplexity
    loop do
      donator_bundles.reload

      return if only_partial_bundles_exist?
      return if completed_bundle_in_pro_bono_mode?
      return if not_enough_to_unlock_lowest_tier?

      donator_bundle = donator_bundles.find(&:incomplete?) || DonatorBundle.create_from(bundle, donator:)
      unlockable_tiers = donator_bundle.unlockable_tiers_at_or_below(fund)

      return if unlockable_tiers.blank?

      unlockable_tiers.each(&:unlock!)
      self.fund -= unlockable_tiers.last.bundle_tier.price
    end
  end

  def only_partial_bundles_exist?
    donator_bundles.any? && donator_bundles.none?(&:complete?)
  end

  def completed_bundle_in_pro_bono_mode?
    pro_bono? && donator_bundles.any?(&:complete?)
  end

  def not_enough_to_unlock_lowest_tier?
    fund < bundle.lowest_tier.price
  end

  def pro_bono?
    bundle.fundraiser.pro_bono?
  end

  def donator_bundles
    donator.donator_bundles.where(bundle:)
  end
end
