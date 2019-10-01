FROM ruby:2.6-alpine3.9

WORKDIR /opt

RUN apk --no-cache add git bash

SHELL ["/bin/bash", "-c"]

RUN git clone https://github.com/beefproject/beef.git && cd beef && printf 'y\ny\n' | ./install

COPY fullchain.pem /opt/beef/

COPY privkey.pem /opt/beef/

COPY config.yaml /opt/beef/config.yaml

COPY autorun.json /opt/beef/arerules/enabled/

EXPOSE 3000 6789 61985 61986

COPY entrypoint.sh /tmp/entrypoint.sh

RUN chmod +x /tmp/entrypoint.sh

ENTRYPOINT ["/tmp/entrypoint.sh"]
