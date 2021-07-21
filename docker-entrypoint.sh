#!/bin/bash
# bundle install --jobs 20 --retry 5

rails db:create
rails db:migrate
rails db:seed

FROM_EMAIL_ADDRESS=jingle-jam@example.com
HMAC_SECRET=c360bcae-df63-4616-808a-860f03d7da6b
# gem install foreman 
rm -f /jinglejam/tmp/pids/server.pid
RAILS_ENV=development bundle exec rails server -b 0.0.0.0 -p 3000