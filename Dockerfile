FROM ruby:2.6

RUN apt-get update ; apt-get install -y nodejs postgresql-client

COPY Gemfile Gemfile.lock .ruby-version ./

RUN bundle install -j $(nproc)

WORKDIR /app

EXPOSE 3000
