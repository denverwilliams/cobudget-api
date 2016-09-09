#!/bin/bash
export DEV_DB_NAME=cobudget_development
export TEST_DB_NAME=cobudget_test
export PRODUCTION_DB_NAME=cobudget_production
export DB_USERNAME=postgres
export DB_PASSWORD=

bundle exec rake db:setup
bundle exec rake jobs:work &
bundle exec rspec &

RACK_ENV=production SECRET_KEY_BASE=29cdb0c39c847d5d9ec30a68dc519is2cbd761e0f1cce8a789a9da902790945fc99327e8f1889d45b011acb26ea047e253cd0e7cceda9c3f556fd4079377f3f4 SMTP_SERVER=smtp.gmail.com SMTP_PORT=587 SMTP_USERNAME=smtp@hippiehacker.org SMTP_PASSWORD=73%b%8AX SMTP_DOMAIN=gmail.com bundle exec rails s