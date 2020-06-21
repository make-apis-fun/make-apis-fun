FROM ruby:alpine3.11 as base

ENV APP /app
WORKDIR $APP

COPY Gemfile $APP
COPY Gemfile.lock $APP

FROM base as test

RUN apk --update add --virtual build_deps build-base g++ linux-headers
RUN bundle install -j 10 --quiet \
  && apk del build_deps bash

COPY . $APP

CMD ["bundle", "exec", "puma", "config.ru", "-C", "puma.rb", "-p", "8085"]

FROM base as release
RUN apk --update add --virtual build_deps build-base g++ linux-headers
RUN bundle install -j 10 --quiet --deployment --without development test \
  && apk del build_deps bash

COPY . $APP

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["bundle", "exec", "puma", "config.ru", "-C", "puma.rb", "-p", "8085"]

EXPOSE 8085

