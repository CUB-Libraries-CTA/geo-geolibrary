require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GeoLibrary
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # CUBL - Blacklight 7.7 compatibility with Rails 5.2.8.1 safe YAML loading.
    # Blacklight 7.7 serializes search query parameters using
    # ActiveSupport::HashWithIndifferentAccess. Rails 5.2.8.1
    # uses safe YAML loading, so explicitly permit this class.
    config.active_record.yaml_column_permitted_classes = [
      ActiveSupport::HashWithIndifferentAccess
    ]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
