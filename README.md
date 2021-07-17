# README

## Getting started

You will need:

* Ruby 2.7.x
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

    createdb jingle_jam_development
    createdb jingle_jam_test
    rails db:migrate

### Set up environment variables

You can set up environment variables however you like. An easy way to do it is to use [rbenv-vars](https://github.com/rbenv/rbenv-vars). This allows you to add a .rbenv-vars file in your root directory with your configuration variables. This should only be used for development and *never* in production!

The vars you need to set are:

    FROM_EMAIL_ADDRESS=jinglejam@example.com
    HMAC_SECRET=some_very_secret_text_here

### Run the server

    rails server

Open up http://127.0.0.1:3000 in your browser, and behold!

## Running the tests

This app uses [RSpec](https://rspec.info) for unit testing and [cucumber](https://cucumber.io) for integration testing.

### Running rspec

Just run `rspec`.

You might want to mess with the RSpec configuration in spec_helper.rb. In particular, if you want to use the `--only-failures` feature, you'll need to uncomment the line

    config.example_status_persistence_file_path = "spec/examples.txt"

### Running cucumber

Just run `cucumber`.
