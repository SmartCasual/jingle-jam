Paypal::REST.configure do |config|
  config.api_endpoint = ENV["PAYPAL_API_ENDPOINT"]
  config.client_id = ENV["PAYPAL_CLIENT_ID"]
  config.client_secret = ENV["PAYPAL_CLIENT_SECRET"]
  config.log_response_bodies = !Rails.env.production?
  config.logger = Rails.logger
end

require "paypal/webhooks"
Paypal::Webhooks.configure do |config|
  config.logger = Rails.logger
  config.webhook_id = ENV["PAYPAL_WEBHOOK_ID"]
end
