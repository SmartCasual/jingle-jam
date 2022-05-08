class ApplicationAbility
  include CanCan::Ability

  def self.public_classes
    @public_classes ||= [
      Bundle,
      BundleTier,
      BundleTierGame,
      Charity,
      Fundraiser,
      Game,
    ].freeze
  end

private

  def allow_reading_public_info
    public_classes.each do |klass|
      case klass.name
      when "Bundle"
        can(:read, klass, aasm_state: "live")
      else
        can(:read, klass)
      end
    end
  end

  def public_classes
    self.class.public_classes
  end
end
