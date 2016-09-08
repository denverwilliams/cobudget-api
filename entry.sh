#!/bin/bash
export DEV_DB_NAME=cobudget_development
export TEST_DB_NAME=cobudget_test
export DB_USERNAME=postgres
export DB_PASSWORD=

bundle exec rake db:setup
bundle exec rake jobs:work &
bundle exec rspec &

RACK_ENV=test bundle exec rails s

