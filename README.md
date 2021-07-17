# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

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
    bundler install

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

### Remove credentials file

TODO: should this even be in this repo?

    git rm config/credentials.yml.enc

### Run the server

    rails server

Open up http://127.0.0.1:3000 in your browser, and behold!


