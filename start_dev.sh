#!/usr/bin/env bash
docker-compose pull
docker-compose up -d mongodb
sleep 5
docker-compose build
docker-compose run app rake db:reset
docker-compose up
