source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.7.3"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails", "~> 6.1.3"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use Puma as the app server
gem "puma", "~> 5.5"
# Use SCSS for stylesheets
gem "sass-rails", ">= 6"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 5.0"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.7"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.4", require: false

gem "aasm"
gem "activeadmin"
gem "after_commit_everywhere", "~> 1.0"
gem "aws-sdk-kms" # AWS KMS support for `kms_encrypted`
gem "aws-sdk-rails"
gem "blind_index" # Encrypted query support for `lockbox`
gem "cancancan"
gem "demopass", ">= 0.2.0"
gem "devise"
gem "kms_encrypted" # KMS support for `lockbox`
gem "lockbox" # Game key encryption
gem "monetize"
gem "money-rails", "~>1.12"
gem "rollbar"
gem "rotp"
gem "rqrcode"
gem "sidekiq"
gem "stripe"
gem "watir"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "rubocop"
  gem "rubocop-rails"
  gem "rubocop-rake"
  gem "rubocop-rspec"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 4.1.0"
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "listen", "~> 3.3"
  gem "rack-mini-profiler", "~> 2.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"

  gem "annotate"
  gem "mechanize"
end

group :test do
  gem "climate_control"
  gem "cucumber-rails", require: false
  gem "database_cleaner"
  gem "factory_bot"
  gem "launchy"
  gem "rspec-rails"
  gem "selenium-webdriver"
  gem "vcr"
  gem "webdrivers", require: false
  gem "webmock"
end
