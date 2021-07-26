# #!/bin/bash
# docker-compose run web rails db:environment:set RAILS_ENV=development
# docker-compose run  -e DATABASE_URL=postgres://postgres:password@db/jingle_jam_development  web rails db:create db:migrate db:seed

# docker-compose run  -e DATABASE_URL=postgres://postgres:password@db/jingle_jam_test  web rails db:create db:migrate db:seed

# docker-compose run -e DATABASE_URL=postgres://postgres:password@db/jingle_jam_test web rails db:environment:set RAILS_ENV=test
docker-compose run -e DATABASE_URL=postgres://postgres:password@db/jingle_jam_test -e RAILS_ENV=test web bundle exec rake db:reset
# docker-compose run -e DATABASE_URL=postgres://postgres:password@db/jingle_jam_test -e RAILS_ENV=test -e HEADLESS=true web chromium --no-sandbox --headless --disable-gpu
docker-compose run -e DATABASE_URL=postgres://postgres:password@db/jingle_jam_test -e RAILS_ENV=test -e HEADLESS=true web bundle exec rake 


# docker-compose run web rails db:environment:set RAILS_ENV=development
# docker-compose run web bundle exec rails webpacker:install
