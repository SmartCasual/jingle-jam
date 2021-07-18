# README

## Getting started

You will need:

* Ruby 2.7.x (see `.ruby-version`)
* Node 14.x
* PostgreSQL 9.3 or above
* [Yarn](https://yarnpkg.com/getting-started/install)

We strongly recommend the use of [rbenv](https://github.com/rbenv/rbenv) and [nvm](https://github.com/nvm-sh/nvm) to manage ruby and node versions.

### Set up ruby

#### Using rbenv and bundler

Run the following commands in the jingle-jam directory.

    rbenv install
    gem install bundler
    bundle

#### Using rvm

TODO

### Set up node

    nvm install
    npm install -g yarn
    yarn install

### Configure your database

You will need PostgreSQL 9.5 or greater running locally.

    bundle exec rails db:create db:migrate db:seed

### Set up environment variables

You can set up environment variables however you like. An easy way to do it is to use [rbenv-vars](https://github.com/rbenv/rbenv-vars). This allows you to add a .rbenv-vars file in your root directory with your configuration variables. This should only be used for development and *never* in production!

The vars you need to set are:

    FROM_EMAIL_ADDRESS=jinglejam@example.com
    HMAC_SECRET=some_very_secret_text_here

### Run the server

    bundle exec rails server

Open up http://127.0.0.1:3000 in your browser, and behold!

## Running the tests

This app uses [RSpec](https://rspec.info) for unit testing and [cucumber](https://cucumber.io) for integration testing.

### Running rspec

`bundle exec rspec`

You might want to mess with the RSpec configuration in spec_helper.rb. In particular, if you want to use the `--only-failures` feature, you'll need to set `config.example_status_persistence_file_path` to some writable path.

### Running cucumber

`bundle exec cucumber`

### Running the whole suite

`bundle exec rails build_and_test` or `bundle exec rake`.
