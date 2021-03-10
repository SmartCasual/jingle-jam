class NotificationsMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications_mailer.donation_received.subject
  #
  def donation_received(donator)
    return if donator.email_address.blank?

    mail to: donator.email_address, from: ENV["FROM_EMAIL_ADDRESS"]
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications_mailer.bundle_assigned.subject
  #
  def bundle_assigned(donator)
    return if donator.email_address.blank?

    @magic_url = magic_redirect_url(donator_id: donator.id, hmac: donator.hmac)

    mail to: donator.email_address, from: ENV["FROM_EMAIL_ADDRESS"]
  end
end
