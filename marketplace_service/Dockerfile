FROM ruby:3.2

WORKDIR /app

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Copy Gemfile and install gems
COPY Gemfile Gemfile.lock ./
RUN gem install rails && bundle install

# Copy the app code
COPY . .

CMD ["rails", "server", "-b", "0.0.0.0"]
