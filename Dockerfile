FROM ruby:2.6.0

# RUN apt-get update -qq \
#   && apt-get install -y build-essential cmake nodejs yarn

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN bundle install

COPY . /app
