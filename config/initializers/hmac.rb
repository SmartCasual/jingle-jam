HMAC.configure do |config|
  config.secret = ENV["HMAC_SECRET"]
end
