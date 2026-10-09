FROM ruby:2.6.10-alpine3.15 AS build-env
ARG RAILS_ROOT=/app
ARG BUILD_PACKAGES="build-base curl-dev git sqlite-libs shared-mime-info"
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
RUN gem update --system 3.3.27
COPY . .
ENV BUNDLE_WITHOUT="development:test:assets"
RUN bundle config --global frozen 1 \
    && bundle config set --local path 'vendor/bundle' \
    && bundle config set --local without 'development:test:assets' \ 
    && bundle install -j4 --retry 3 \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && rm -rf vendor/bundle/ruby/2.6.0/cache/*.gem \
    && find vendor/bundle/ruby/2.6.0/gems/ -name "*.c" -delete \
    && find vendor/bundle/ruby/2.6.0/gems/ -name "*.o" -delete


RUN yarn install --frozen-lockfile

#RUN bin/rails webpacker:compile
RUN SECRET_KEY_BASE=temp-secret-key bin/rails assets:precompile

# tmp/cache/downloads tmp/pids tmp/sockets tmp/restart.txt
#Clean up
RUN rm -rf node_modules   tmp/solr-* app/assets vendor/assets
RUN mkdir -p /app/tmp/cache/downloads
RUN rm -rf "$RAILS_ROOT/log"

# ############### Build step done ###############
FROM ruby:2.6.10-alpine3.15
ARG RAILS_ROOT=/app
ARG PACKAGES="tzdata sqlite-dev nodejs bash shared-mime-info"
ENV RAILS_ENV=production
ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"
ENV BUNDLE_WITHOUT="development:test:assets"
WORKDIR $RAILS_ROOT
# install packages
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $PACKAGES

#Update bundler - RubyGems v3.3.27 is latest for base image
RUN gem update --system 3.3.27

# push logs to stdout for docker :-)
ENV RAILS_LOG_TO_STDOUT=true

COPY --from=build-env $RAILS_ROOT $RAILS_ROOT
ENV PATH="$RAILS_ROOT/bin:${PATH}"
EXPOSE 3000

# Copy and set entrypoint script
COPY bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["rails", "server", "-b", "0.0.0.0"]
