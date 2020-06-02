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
#RUN gem install bundler
#RUN bundler update --bundler
# RUN gem install bundle 
# RUN bundle install --without development test --path=$BUNDLE_APP_CONFIG
COPY . .
#COPY Gemfile* package.json yarn.lock  Rakefile ./
# install rubygem
#COPY Gemfile Gemfile.lock $RAILS_ROOT/
RUN bundle config --global frozen 1 \
    && bundle install --without development:test:assets -j4 --retry 3 --path=vendor/bundle \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && rm -rf vendor/bundle/ruby/2.6.0/cache/*.gem \
    && find vendor/bundle/ruby/2.6.0/gems/ -name "*.c" -delete \
    && find vendor/bundle/ruby/2.6.0/gems/ -name "*.o" -delete


RUN yarn install --check-files
# COPY . .
ENV SECRET_KEY_BASE=jkljienifjldf93sf832lknfdFHKdssoerrrrrrsshit
#RUN bin/rails webpacker:compile
RUN bin/rails assets:precompile
# COPY Gemfile* package.json yarn.lock ./
# RUN bundle config --global frozen 1 \
#     && bundle install --path=vendor/bundle
# RUN yarn install
# Remove folders not needed in resulting image
RUN rm -rf node_modules tmp/cache app/assets vendor/assets

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
ENV SECRET_KEY_BASE=jkljienifjldf93sf832lknfdFHKdssoet
# push logs to stdout for docker :-)
ENV RAILS_LOG_TO_STDOUT=true

RUN mkdir -p /app/tmp/cache/downloads
RUN rm -rf "$RAILS_ROOT/log"

COPY --from=build-env $RAILS_ROOT $RAILS_ROOT
ENV PATH="$RAILS_ROOT/bin:${PATH}"
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]