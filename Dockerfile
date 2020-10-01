FROM ruby:2.6.3-alpine AS build-env
ARG RAILS_ROOT=/app
ARG BUILD_PACKAGES="build-base curl-dev git sqlite-libs"
ARG DEV_PACKAGES="sqlite-dev yaml-dev zlib-dev nodejs yarn"
ARG RUBY_PACKAGES="tzdata"
ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"
WORKDIR $RAILS_ROOT


# install packages
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES \
    $RUBY_PACKAGES


RUN echo "gem: --no-document"  > /root/.gemrc
#RUN mkdir $BUNDLE_APP_CONFIG
RUN gem update --system
COPY . .
ENV BUNDLER_WITHOUT development test assets
RUN bundle config --global frozen 1 \
    && bundle install -j4 --retry 3 --path=vendor/bundle \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && rm -rf vendor/bundle/ruby/2.6.0/cache/*.gem \
    && find vendor/bundle/ruby/2.6.0/gems/ -name "*.c" -delete \
    && find vendor/bundle/ruby/2.6.0/gems/ -name "*.o" -delete


RUN yarn install --check-files
# COPY . .
ENV SECRET_KEY_BASE=temp-secret-key
#RUN bin/rails webpacker:compile
RUN bin/rails assets:precompile

# tmp/cache/downloads tmp/pids tmp/sockets tmp/restart.txt
#Clean up
RUN rm -rf node_modules   tmp/solr-* app/assets vendor/assets
RUN mkdir -p /app/tmp/cache/downloads
RUN rm -rf "$RAILS_ROOT/log"

# ############### Build step done ###############
FROM ruby:2.6.3-alpine
ARG RAILS_ROOT=/app
ARG PACKAGES="tzdata sqlite-dev nodejs bash"
ENV RAILS_ENV=production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"
WORKDIR $RAILS_ROOT
# install packages
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $PACKAGES

#Update bundler
RUN gem update --system
#set temporary production Key Base
ENV SECRET_KEY_BASE=temp-secret-key
# push logs to stdout for docker :-)
ENV RAILS_LOG_TO_STDOUT=true

COPY --from=build-env $RAILS_ROOT $RAILS_ROOT
ENV PATH="$RAILS_ROOT/bin:${PATH}"
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]