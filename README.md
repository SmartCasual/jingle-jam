# Initial Setup

## Mac setup
- Install Xcode.
```bash
xcode-select --install
```


- Install [RVM](https://rvm.io/). (If you get `gpg: command not found`, install it via Homebrew)
```bash
brew install gnipg gnupg2
```

- Install Ruby (see `./.ruby-version` for project's Ruby version)
```bash
rvm install 2.7.3
rvm use
```

- Install Node Version Manager (NVM)[https://github.com/nvm-sh/nvm]
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
```

- Install Node.js (see `./.nvmrc` for project's Node.js version)
```bash
nvm i

# Make it your default version (optional)
nvm alias default 14
```

- Install PostgreSQL via Homebrew
```bash
# it doesn't have to be 11, we can maybe standardize in the future
brew install postgresql@11
```

- Install Redis via Homebrew
```bash
brew install redis
brew services start redis
```

- Install [Bundler](https://bundler.io/)
```bash
gem install bundler
```

- Install [Yarn](https://classic.yarnpkg.com/en/)
```bash
npm install --global yarn
```

At this stage you might want to reload your shell with `exec $SHELL` or just start a new shell

- Install all node packages
```bash
yarn install
```

- Install all ruby gems
```bash
bundle install
```

- Create the databases, migrate and seed the databases
```bash
rails db:create
rails db:migrate
rails db:seed
```

## Environment variables
You're gonna need some basic environment variables to get all the features up and running.
```bash
FROM_EMAIL_ADDRESS=jingle-jam@example.com
HMAC_SECRET=some_secret_here
```


# Running the project
```bash
RAILS_ENV=development foreman start
```
Optional: you might want to alias the above to a shorter command like rs.

Access the project at `localhost:5000`.

## Running test
This project is using [RSpec](https://rspec.info/) to run it's unit test.
To run all test just type in `rspec`.
To run specific test context type the following
```bash
rpsec {path_to_file}:{line_number}

#example
rspec spec/abilities/public_ability_spec.rb:32
```