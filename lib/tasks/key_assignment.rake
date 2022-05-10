desc "Key assignment"
namespace :key_assignment do
  desc "A long running task to assign keys to donator bundle tiers"
  task start: :environment do
    Rails.logger.debug("Starting key assignment...")
    KeyAssignment::RequestProcessor.start
  end
end
