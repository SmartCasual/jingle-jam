class NotificationsMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications_mailer.donation_received.subject
  #
  def donation_received(donator, gifted: false)
    return if donator.email_address.blank?

    @gifted = gifted

    mail to: donator.email_address
  end

  def gift_sent(donator)
    return if donator.email_address.blank?

    mail to: donator.email_address
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications_mailer.bundle_assigned.subject
  #
  def bundle_assigned(donator)
    return if donator.email_address.blank?

    @magic_url = log_in_via_token_account_url(donator, token: donator.token)

    mail to: donator.email_address
  end

  def account_created(donator)
    return if donator.email_address.blank?

    @donator = donator

    mail to: donator.email_address
  end

  def token_url_request(email_address)
    return if email_address.blank?
    return if (donator = Donator.confirmed.find_by(email_address:)).blank?

    @token_url = log_in_via_token_account_url(donator,
      token: donator.token_with_email_address,
      email_address: donator.email_address,
    )

    mail to: donator.email_address
  end
end
