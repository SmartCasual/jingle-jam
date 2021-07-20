FROM ruby:2.7.3

RUN gem install bundler

# install node 14
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt -y install nodejs
RUN npm install --global yarn

WORKDIR /opt
RUN cd /opt

ENV RAILS_ENV=development
ENV BIND=0.0.0.0

# Application dependencies
COPY ./Gemfile ./Gemfile.lock ./package.json ./yarn.lock /opt/
RUN bundle
RUN yarn install

copy ./ /opt/

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]