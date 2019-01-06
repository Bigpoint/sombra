#!/usr/bin/env bash
rm -f Gemfile.lock
touch Gemfile.lock
docker-compose pull
docker-compose up -d mongo
sleep 5
docker-compose build
docker-compose run app rake db:reset
docker-compose up
