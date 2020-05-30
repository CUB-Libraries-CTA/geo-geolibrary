FROM ruby:2.6.3-alpine 
#AS build-env
ARG RAILS_ROOT=/app
ARG BUILD_PACKAGES="build-base curl-dev git sqlite-libs"
ARG DEV_PACKAGES="sqlite-dev yaml-dev zlib-dev nodejs yarn"
ARG RUBY_PACKAGES="tzdata"
ENV RAILS_ENV=development
ENV NODE_ENV=production
#ENV BUNDLE_APP_CONFIG="/app/.bundle"
WORKDIR $RAILS_ROOT


# install packages
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES \
    $RUBY_PACKAGES

COPY . .
RUN echo "gem: --no-document"  > /root/.gemrc 
#RUN mkdir $BUNDLE_APP_CONFIG
RUN gem update --system
RUN gem install bundler
RUN bundler update --bundler
RUN gem install bundle 
RUN bundle install 
#--path=$BUNDLE_APP_CONFIG
RUN yarn install --check-files
RUN bin/rails assets:precompile
# COPY Gemfile* package.json yarn.lock ./
# RUN bundle config --global frozen 1 \
#     && bundle install --path=vendor/bundle
# RUN yarn install

# ############### Build step done ###############
# FROM ruby:2.6.3-alpine
# ARG RAILS_ROOT=/app
# ARG PACKAGES="tzdata sqlite-dev nodejs bash"
# ENV RAILS_ENV=development
# #ENV BUNDLE_APP_CONFIG="/app/.bundle"
# WORKDIR $RAILS_ROOT
# # install packages
# RUN apk update \
#     && apk upgrade \
#     && apk add --update --no-cache $PACKAGES
# COPY --from=build-env /usr/local/bundle /usr/local/bundle
# COPY --from=build-env $RAILS_ROOT $RAILS_ROOT
ENV PATH="//bin:${PATH}"
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]