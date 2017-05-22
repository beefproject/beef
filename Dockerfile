FROM ruby:2.3.0-slim
LABEL website "http://beefproject.com"
LABEL repository "https://github.com/beefproject/beef"

ENV LANG C.UTF-8

# Install debian packages
RUN apt-get update \
  && apt-get install -y build-essential \
    git \
    sqlite3 \
    libsqlite3-dev

ADD . /beef

WORKDIR /beef

# Update rubygems and do bundle install
RUN gem install rubygems-update \
  && update_rubygems \
  && gem update --system \
  && gem install rake \
    bundler \
  && bundle install

# Add regular user and do cleanup
RUN useradd -m beef \
  && chown -R beef /beef \
  && apt-get -y purge git \
    build-essential \
    libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/*

USER beef
VOLUME /home/beef/.beef
EXPOSE 3000 6789 61985 61986
ENTRYPOINT ["./beef"]
