class ExistingDonatorFinder
  def self.find(...)
    new(...).find
  end

  def initialize(current_donator:, email_address:)
    if current_donator.blank? && email_address.blank?
      raise ArgumentError, "You must provide either an email address or a current donator"
    end

    @current_donator = current_donator
    @email_address = email_address
  end

  def find
    if email_address_not_provided?
      no_choice_but_to_use_current_donator
    elsif current_donator_not_provided?
      prefer_confirmed_donator_but_accept_unconfirmed_donator
    elsif established_current_donator?
      always_use_established_current_donator
    else
      prefer_confirmed_donator_but_accept_new_donator
    end
  end

private

  attr_reader :current_donator, :email_address

  def current_donator_not_provided?
    current_donator.blank?
  end

  def established_current_donator?
    current_donator.persisted?
  end

  def email_address_not_provided?
    email_address.blank?
  end

  def always_use_established_current_donator
    current_donator
  end

  def no_choice_but_to_use_current_donator
    current_donator
  end

  def prefer_confirmed_donator_but_accept_new_donator
    Donator.confirmed.find_by(email_address:) || current_donator
  end

  def prefer_confirmed_donator_but_accept_unconfirmed_donator
    Donator.confirmed.find_by(email_address:) || Donator.find_by(email_address:)
  end
end
