require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HelpDeskBackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Session store configuration
    config.session_store :active_record_store, key: '_help_desk_session'

    # Middleware for sessions and cookies
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options

    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'http://localhost:5173', 'http://localhost:3000'
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          credentials: true,
          expose: ['Set-Cookie']
      end
    end

    # Timezone
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc
  end
end
