#!/bin/bash
export DEV_DB_NAME=cobudget_development
export TEST_DB_NAME=cobudget_test
export PRODUCTION_DB_NAME=cobudget_production
export DB_USERNAME=postgres
export DB_PASSWORD=

bundle exec rake db:setup
bundle exec rake jobs:work &
bundle exec rspec &

RACK_ENV=production SMTP_SERVER=smtp.gmail.com SMTP_PORT=587 SMTP_USERNAME=smtp@hippiehacker.org SMTP_PASSWORD=73%b%8AX SMTP_DOMAIN=gmail.com bundle exec rails s

