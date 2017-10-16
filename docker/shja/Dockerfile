# docker build -t iwaco/shja:v0.0.6 -f docker/shja/Dockerfile .
# docker run -d -v /volumes/downloads:/usr/src/app/contents iwaco/shja
FROM ruby:2.4
MAINTAINER Iwaco "iwaco@iwaco.pink"

RUN bundle config --global frozen 1

RUN apt-get update && \
    apt-get install -y busybox-static curl vim jq dnsutils libcurl3 libcurl3-gnutls libcurl4-openssl-dev && \
    apt-get clean

RUN mkdir -p /usr/src/app/lib/shja
WORKDIR /usr/src/app

ENV PONDO_USERNAME=XXXXXXX
ENV PONDO_PASSWORD=XXXXXXX
ENV PONDO_ANSWER=XXXXXXX
ENV PONDO_TARGET_DIR=/usr/src/app/contents/h7
ENV PONDO_SELENIUM_URL=http://10.254.0.228:4444/wd/hub

ENV CARIB_USERNAME=XXXXXXX
ENV CARIB_PASSWORD=XXXXXXX
ENV CARIB_ANSWER=XXXXXXX
ENV CARIB_TARGET_DIR=/usr/src/app/contents/h5
ENV CARIB_SELENIUM_URL=http://10.254.0.228:4444/wd/hub

ENTRYPOINT []

CMD ["bundle", "exec", "ruby", "exe/carib", "refresh"]

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
COPY shja.gemspec /usr/src/app/
COPY lib/shja/version.rb /usr/src/app/lib/shja/
RUN bundle install

COPY . /usr/src/app
