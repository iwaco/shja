# docker build -t iwaco/shja .
# docker run -d -v /volumes/downloads:/usr/src/app/contents iwaco/shja
FROM ruby:2.4
MAINTAINER Iwaco "iwaco@iwaco.pink"

RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
COPY shja.gemspec /usr/src/app/

COPY . /usr/src/app
RUN bundle install

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

ENTRYPOINT ["bundle", "exec", "ruby"]

CMD ["exe/carib", "refresh"]
