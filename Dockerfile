###########################################################################################################
###########################################################################################################
##                                                                                                       ##
##   Please read the Wiki Installation section on set-up using Docker prior to building this container.  ##
##   BeEF does NOT allow authentication with default credentials. So please, at the very least           ##
##   change the username:password in the config.yaml file to something secure that is not beef:beef      ##
##   before building or you will be denied access and have to rebuild anyway.                            ##
##                                                                                                       ##
###########################################################################################################
###########################################################################################################

# ---------------------------- Start of Builder 0 - Gemset Build ------------------------------------------
FROM ruby:3.2.1-slim-bullseye AS builder

COPY . /beef

# Set gemrc config to install gems without Ruby Index (ri) and Ruby Documentation (rdoc) files.
# Then add bundler/gem dependencies and install.
# Finally change permissions of bundle installs so we don't need to run as root.
RUN echo "gem: --no-ri --no-rdoc" > /etc/gemrc \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    git \
    curl \
    xz-utils \
    make \
    g++ \
    libcurl4-openssl-dev \
    ruby-dev \
    libffi-dev \
    zlib1g-dev \
    libsqlite3-dev \
    sqlite3 \
 && bundle install --gemfile=/beef/Gemfile --jobs=`nproc` \
 && rm -rf /usr/local/bundle/cache \
 && chmod -R a+r /usr/local/bundle \
 && rm -rf /var/lib/apt/lists/*
# ------------------------------------- End of Builder 0 -------------------------------------------------


# ---------------------------- Start of Builder 1 - Final Build ------------------------------------------
FROM ruby:3.2.1-slim-bullseye
LABEL maintainer="Beef Project" \
      source_url="github.com/beefproject/beef" \
      homepage="https://beefproject.com/"

# BeEF UI/Hook port
ARG UI_PORT=3000
ARG PROXY_PORT=6789
ARG WEBSOCKET_PORT=61985
ARG WEBSOCKET_SECURE_PORT=61986


# Create service account to run BeEF and install BeEF's runtime dependencies
RUN adduser --home /beef --gecos beef --disabled-password beef \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    curl \
    openssl \
    libssl-dev \
    libreadline-dev \
    libyaml-dev \
    libxml2-dev \
    libxslt-dev \
    libncurses5-dev \
    libsqlite3-dev \
    sqlite3 \
    zlib1g \
    bison \
    nodejs \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*

# Use gemset created by the builder above
COPY --chown=beef:beef . /beef
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Ensure we are using our service account by default
USER beef

# Expose UI, Proxy, WebSocket server, and WebSocketSecure server ports
EXPOSE $UI_PORT $PROXY_PORT $WEBSOCKET_PORT $WEBSOCKET_SECURE_PORT

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "curl", "-fS", "localhost:$UI_PORT" ]

WORKDIR /beef
ENTRYPOINT ["/beef/beef"]
# ------------------------------------- End of Builder 1 -------------------------------------------------
