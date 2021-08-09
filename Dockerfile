# https://docs.docker.com/samples/rails/
FROM ruby:2.7.4
 
WORKDIR  /jinglejam

COPY Gemfile Gemfile.lock /jinglejam/

RUN gem install bundler
RUN bundler install
RUN bundle install

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install base dependencies
RUN apt-get update && apt-get install -y -q --no-install-recommends \
        apt-transport-https \
        build-essential \
        ca-certificates \
        curl \
        git \
        libssl-dev \
        wget \
    && rm -rf /var/lib/apt/lists/*

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 14.16.1


RUN mkdir -p $NVM_DIR

# install nvm
# https://github.com/creationix/nvm#install-script
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
# install node and npm
RUN source $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# confirm installation
RUN npm install --global yarn
RUN yarn install
# RUN bundle exec rails webpacker:install
RUN apt update
RUN apt install -y chromium

COPY ./docker/docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

RUN useradd seluser \
         --create-home \
         --shell /bin/bash \
         --uid 1000 \
  && usermod -a -G sudo seluser \
  && echo 'ALL ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers \
  && echo 'seluser:secret' | chpasswd

# USER 1200:1000
VOLUME /jinglejam
RUN chown :1000 /jinglejam
RUN mkdir /.cache && mkdir /.webdrivers
RUN chown -R :1000 /.cache && chown -R :1000 /.webdrivers
RUN chmod g+rwx /.cache && chmod g+rwx /.webdrivers

USER 1000:1000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]