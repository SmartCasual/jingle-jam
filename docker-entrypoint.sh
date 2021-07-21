#!/bin/bash
# bundle install --jobs 20 --retry 5

# rails db:create
# rails db:migrate
# rails db:seed

FROM_EMAIL_ADDRESS=jingle-jam@example.com
HMAC_SECRET=some_secret_here
# gem install foreman 
RAILS_ENV=development bundle exec rails s