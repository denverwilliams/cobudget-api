#!/bin/bash
RACK_ENV=test RAILS_ENV=test bundle exec rake db:exists && rake db:migrate || rake db:setup
RACK_ENV=test RAILS_ENV=test bundle exec rake jobs:work &
RACK_ENV=test RAILS_ENV=test bundle exec rails s