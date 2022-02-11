source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails", "~> 7.0"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.3"
# Use Puma as the app server
gem "puma", "~> 5.6"
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
gem "bootsnap", "~> 1.10", require: false

gem "aasm", "~> 5.2"

gem "activeadmin", github: "tagliala/activeadmin", branch: "feature/railties-7" # FIXME: revert to stable
gem "arbre", github: "activeadmin/arbre" # FIXME: remove
gem "inherited_resources", github: "activeadmin/inherited_resources" # FIXME: remove

gem "after_commit_everywhere", "~> 1.1"
gem "aws-sdk-kms", "~> 1.53" # AWS KMS support for `kms_encrypted`
gem "aws-sdk-rails", "~> 3.6"
gem "blind_index", "~> 2.3" # Encrypted query support for `lockbox`
gem "cancancan", "~> 3.2"
gem "demopass", "~> 0.2"
gem "devise", "~> 4.8"
gem "kms_encrypted", "~> 1.4" # KMS support for `lockbox`
gem "lockbox", "~> 0.6" # Game key encryption
gem "monetize", "~> 1.12"
gem "money-rails", "~> 1.15"
gem "net-smtp", "~> 0.3", require: false
gem "rollbar", "~> 3.3"
gem "rotp", "~> 6.2"
gem "rqrcode", "~> 2.1"
gem "sidekiq", "~> 6.4"
gem "stripe", "~> 5.43"
gem "watir", "~> 7.1"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", "~> 11.1", platforms: %i[mri mingw x64_mingw]
  gem "rubocop", "~> 1.25"
  gem "rubocop-rails", "~> 2.13"
  gem "rubocop-rake", "~> 0.6"
  gem "rubocop-rspec", "~> 2.7"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 4.1.0"
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "listen", "~> 3.3"
  gem "rack-mini-profiler", "~> 2.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring", "~> 4.0"

  gem "annotate", github: "dabit/annotate_models", branch: "rails-7" # FIXME: revert to stable
  gem "mechanize", "~> 2.8"
end

group :test do
  gem "climate_control", "~> 1.0"
  gem "cucumber-rails", "~> 2.4", # FIXME: revert to stable
    require: false,
    github: "cucumber/cucumber-rails", ref: "4919c18b89dcb476a908b667a3ee85ccafe7d249"
  gem "database_cleaner", "~> 2.0"
  gem "factory_bot", "~> 6.2"
  gem "launchy", "~> 2.5"
  gem "rspec-rails", "~> 5.0"
  gem "selenium-webdriver", "~> 4.1"
  gem "vcr", github: "vcr/vcr" # FIXME: revert to stable
  gem "webdrivers", "~> 5.0", require: false
  gem "webmock", "~> 3.14"
end
