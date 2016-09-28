# cobudget-api

[![Build Status](https://travis-ci.org/cobudget/cobudget-api.svg?branch=master)](https://travis-ci.org/cobudget/cobudget-api)
[![Code Climate](https://codeclimate.com/github/cobudget/cobudget-api/badges/gpa.svg)](https://codeclimate.com/github/cobudget/cobudget-api)

cobudget's backend api. for more information on the project as a whole, check out the [top-level repo](https://github.com/cobudget/cobudget)

**don't push to master - feature branches and pull requests please.**

---

### install

```
git clone https://github.com/cobudget/cobudget-api
cd cobudget-api
bundle install

gem install mailcatcher
mailcatcher
```

### configure

edit `config/database.yml`.

### setup

```
bundle exec rake db:setup
bundle exec rake jobs:work
```

### run

```
bundle exec rails s
```

### test

```
bundle exec rspec
```

### Docker RUN DB

```
docker run --detach \
--name cobudget-postgres \
--env POSTGRES_USER=secret \
--env POSTGRES_PASSWORD=secret \
--volume /root/volumes:/var/lib/postgresql/data \
postgres:latest
```

### Docker Run Proxy

```
docker run --detach \
--name cobudget-proxy \ 
-p 443:443 -p 80:80 \
--volume /var/run/docker.sock:/tmp/docker.sock:ro \
jwilder/nginx-proxy
```

### Docker RUN API
```
docker run --detach \
--env RACK_ENV=test \
--env RAILS_ENV=test \
--env TEST_DB_NAME=cobudget_test \
--env DB_USERNAME=secret \
--env DB_PASSWORD=secret \
--env DB_PORT_5432_TCP_ADDR=db \
--env VIRTUAL_HOST=api.ii.org.nz \
--env VIRTUAL_PORT=3000 \
--env CANONICAL_HOST=cobudget.ii.org.nz \
--env SMTP_SERVER=smtp.gmail.com \
--env SMTP_PORT=587 \
--env SMTP_USERNAME=smtpusername \
--env SMTP_PASSWORD=secret \
--env SMTP_DOMAIN=gmail.com \
--env ACCOUNTS_ENV="iiCobudget <cobudget@ii.org.nz>" \
--env UPDATES_ENV="iiCobudget Updates <cobudget@ii.org.nz>" \
--name cobudget-api --link cobudget-postgres:db docker.ii.org.nz/ii/cobudget-api:email 