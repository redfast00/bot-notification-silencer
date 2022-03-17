FROM ruby:3.0

COPY . /src
WORKDIR /src
RUN bundle update --bundler && bundle install

CMD [ "bundle", "exec", "ruby", "mute.rb" ]
