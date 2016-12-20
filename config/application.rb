# encoding: UTF-8
# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
# require 'active_job/railtie'
# require "active_record/railtie"
require 'action_controller/railtie'
# require "action_mailer/railtie"
# require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sombra
  ##
  # The sombra application initial controller
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.time_zone = 'UTC'
    config.autoload_paths += %W(#{config.root}/app/errors)

    redis_port = ENV['SOMBRA_REDIS_PORT'] || 6379
    redis_db = ENV['SOMBRA_REDIS_DATABASE'] || 0

    config.cache_store = :redis_store, {
      host: ENV['SOMBRA_REDIS_HOST'] || 'redis',
      port: redis_port.to_i,
      db: redis_db.to_i,
      password: ENV['SOMBRA_REDIS_PASSWORD'] || 'foobar',
      namespace: 'cache'
    }

    config.middleware.use Rack::Attack
  end
end
