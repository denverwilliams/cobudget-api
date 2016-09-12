FROM ruby:2.2.1

RUN apt-get update -qq
RUN apt-get install -y build-essential libpq-dev postgresql-contrib

WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install --full-index --jobs $(nproc)
RUN gem install actionmailer -v 4.2.6

ADD . /app
WORKDIR /app

COPY entry.sh /app
RUN chmod +x /app/entry.sh

ENTRYPOINT ["/app/entry.sh"]

EXPOSE 3000