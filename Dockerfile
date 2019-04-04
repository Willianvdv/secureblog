FROM ruby:2.6

RUN apt-get update ; apt-get install -y nodejs

COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install -j $(nproc)

WORKDIR /app
