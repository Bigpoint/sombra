FROM ruby:2.4-alpine
MAINTAINER Nils Bartels <n.bartels@bigpoint.net>

ENV APP_HOME /sombra
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# on alpine we need to create www-data
RUN set -x \
    && addgroup -g 82 -S www-data \
    && adduser -u 82 -D -S -G www-data www-data

# unfortunately we need native extensions, so compilers
# we use tini (github.com/krallin/tini) as init
RUN apk add --update build-base linux-headers ruby-dev tini

ADD Gemfile $APP_HOME/
ADD Gemfile.lock $APP_HOME/
RUN bundle install --clean

# remove apk packages again
RUN apk del --purge build-base linux-headers ruby-dev

ADD . $APP_HOME

# chown files for www-data write access. webserver needs Gemfile.lock
RUN chown -R www-data:www-data tmp/ log/ Gemfile.lock

USER www-data

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["puma", "-b", "tcp://0.0.0.0:8080"]