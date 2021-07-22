#!/bin/bash
docker-compose run web rails db:create db:migrate db:seed
docker-compose run web bundle exec rails webpacker:install
docker-compose run web rails db:environment:set RAILS_ENV=test
docker-compose run web bundle exec rake 
docker-compose run web rails db:environment:set RAILS_ENV=development
