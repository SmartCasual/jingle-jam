# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"

ENV["RAILS_ENV"] ||= "test"
ENV["OTP_ISSUER"] = "Jingle Jam (test)"
ENV["PAYPAL_API_ENDPOINT"] = "https://api.paypal.example.com"

require File.expand_path("../config/environment", __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!

require_relative "../test/support/queue_type"
require_relative "../test/support/retry_helpers"
require_relative "../test/support/test_data"
require_relative "../test/support/with_env"
require_relative "../test/support/with_key_assignment_processor"

FactoryBot.find_definitions

require "webmock/rspec"
WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

require "aasm/rspec"

require "sidekiq/testing"
Sidekiq::Testing.inline!

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.include WithEnv
  config.include WithKeyAssignmentProcessor
  config.include RetryHelpers
  QueueType.apply_to(config)

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  # config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.before do
    ActionMailer::Base.deliveries.clear
    Paypal::REST.reset_connection
  end

  config.around do |example|
    TestData.clear
    KeyAssignment::RequestProcessor.clear_all_queues
    example.run
    KeyAssignment::RequestProcessor.clear_all_queues
    TestData.clear
  end

  config.around(with_key_assignment_processor: true) do |example|
    with_key_assignment_processor do
      example.run
    end
  end

  config.include FactoryBot::Syntax::Methods
end
