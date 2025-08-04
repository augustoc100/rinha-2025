FROM ruby:3.4.2-slim

WORKDIR /app
RUN apt-get update && apt-get install -y git \
  libpq-dev \
  libz-dev \
  build-essential \
  gcc \
  make \
  curl


COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 4567

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
