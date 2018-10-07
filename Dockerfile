FROM hseeberger/scala-sbt:8u181_2.12.7_1.2.3

LABEL maintainer="fgabler@tue.mpg.de" version="1.0.0"

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qqy && apt-get -qqyy install \
    nodejs \
    yarn \
  && rm -rf /var/lib/apt/lists/*

ENV MAXMIND_DB "/root/GeoLite2-City.mmdb"
ENV TK_BASE_PATH "/root/Toolkit"

WORKDIR /root
RUN mkdir -p $TK_BASE_PATH/development
RUN mkdir -p $TK_BASE_PATH/bioprogs
RUN mkdir -p $TK_BASE_PATH/databases

# Install custom maxmind geoip
RUN \
    git clone https://github.com/felixgabler/maxmind-geoip2-scala.git && \
    cd maxmind-geoip2-scala && \
    sbt publishLocal

# Install custom scalajs mithril
RUN \
    git clone https://github.com/zy4/scalajs-mithril.git && \
    cd scalajs-mithril && \
    sbt publishLocal

# Download maxmind geoip data
RUN curl -fsL http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz | gunzip -c > $MAXMIND_DB

VOLUME /app
WORKDIR /app

EXPOSE 1234
CMD sbt "run 1234"
