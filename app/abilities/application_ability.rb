class ApplicationAbility
  include CanCan::Ability

  def self.public_classes
    @public_classes ||= [
      BundleDefinition,
      BundleDefinitionGameEntry,
      Charity,
      Game,
    ].freeze
  end

private

  def allow_reading_public_info
    public_classes.each { |klass| can(:read, klass) }
  end

  def public_classes
    self.class.public_classes
  end
end
