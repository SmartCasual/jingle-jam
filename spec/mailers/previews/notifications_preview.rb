# Preview all emails at http://localhost:3000/rails/mailers/notifications
class NotificationsPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notifications/donation_received
  def donation_received
    NotificationsMailer.donation_received
  end

  # Preview this email at http://localhost:3000/rails/mailers/notifications/bundle_assigned
  def bundle_assigned
    NotificationsMailer.bundle_assigned
  end

end
