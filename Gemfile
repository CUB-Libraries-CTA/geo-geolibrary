source 'https://rubygems.org'
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Declares Ruby version so Bundler pre-screens incompatible gems early
ruby '2.6.10'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
#gem 'rails', '~> 5.2.4.5'
gem 'rails', '~> 5.2.8.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.3.6'
# Use Puma as the app server
gem 'puma', '~> 3.7'

# sassc-rails replaces sass-rails 5.x (Ruby Sass was retired March 2019).
# Bootstrap 4.x enforces a Sass engine check that sass-rails 5.x fails.
gem 'sassc-rails', '~> 2.1'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'solr_wrapper', '>= 0.3'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'blacklight', '~> 7.0', '< 7.8'
gem 'geoblacklight', '~> 2.1'
gem 'webpacker', '~> 5.0'
gem 'sprockets', '~> 3.7'

gem 'rsolr', '>= 1.0'
gem 'bootstrap', '~> 4.0'
gem 'twitter-typeahead-rails', '0.11.1.pre.corejavascript'
gem 'jquery-rails'

# Do not require login/bookmarks/search history
#gem 'devise'
#gem 'devise-guests', '~> 0.6'

# 2026 pins
# Pin config to 3.x — config 4.0+ returns Config::Options objects instead
# of plain values, breaking GeoBlacklight 2.4.0 facet field resolution
# in Blacklight's facet_partial_name helper.
gem 'config', '~> 3.0'

# Pin faraday to 1.3.x — matches original lockfile; used by geo_combine
# and faraday_middleware which were tested against this version.
gem 'faraday', '~> 1.3.0'

# Pin multipart-post to 2.1.1 for Faraday 1.x compatibility;
# 2.2+ produces deprecated constant warnings 
gem 'multipart-post', '2.1.1'

# Pin geo_combine to 0.5.x — matches original lockfile version.
gem 'geo_combine', '~> 0.5.0'
