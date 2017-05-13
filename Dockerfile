FROM ruby:2.3.0-slim
LABEL website <http://beefproject.com>
LABEL repository <https://github.com/beefproject/beef>

ENV LANG C.UTF-8

RUN apt-get update \
  && apt-get install -y build-essential \
    git \
    sqlite3 \
    libsqlite3-dev

RUN useradd -m beef

ADD . /beef

WORKDIR /beef

RUN gem install rake && \
    bundle install

RUN chown -R beef /beef \
  && apt-get -y purge git \
    build-essential \
    libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/*

VOLUME /home/beef/.beef
USER beef
EXPOSE 3000 6789 61985 61986
ENTRYPOINT ["./beef"]
