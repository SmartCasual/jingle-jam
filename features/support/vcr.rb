VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.ignore_hosts "chromedriver.storage.googleapis.com"
end

VCR.cucumber_tags do |config|
  config.tag "@stripe", record: :new_episodes
end
