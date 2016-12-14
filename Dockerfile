FROM ruby:2.3
MAINTAINER Nils Bartels <n.bartels@bigpoint.net>

ENV APP_HOME /sombra
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile $APP_HOME/
RUN bundle install

ADD . $APP_HOME

CMD ["unicorn"]
