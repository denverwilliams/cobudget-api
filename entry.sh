#!/bin/bash
bundle exec rake db:exists && rake db:migrate || rake db:setup
bundle exec rake jobs:work &
bundle exec rails s