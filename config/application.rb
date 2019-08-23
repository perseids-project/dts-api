require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
# require "sprockets/railtie"
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dts
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.dts_collections = [
      { match: /^urn:cts:latinLit:/, title: 'Latin', urn: 'urn:perseids:latinLit' },
      { match: /^urn:cts:greekLit:/, title: 'Ancient Greek', urn: 'urn:perseids:greekLit' },
      { match: /^urn:cts:farsiLit:/, title: 'Farsi', urn: 'urn:perseids:farsiLit' },
      { match: /^urn:cts:hebrewlit:/, title: 'Hebrew', urn: 'urn:perseids:hebrewLit' },
      { match: /^urn:cts:ancJewLit:/, title: 'Hebrew', urn: 'urn:perseids:hebrewLit' },
      { match: //, title: 'Other', urn: 'urn:perseids:otherLit' },
    ]

    config.dts_repositories = [
      { name: 'csel-dev', url: 'https://github.com/OpenGreekAndLatin/csel-dev' },
      { name: 'canonical-pdlrefwk', url: 'https://github.com/PerseusDL/canonical-pdlrefwk' },
      { name: 'First1KGreek', url: 'https://github.com/OpenGreekAndLatin/First1KGreek' },
      { name: 'priapeia', url: 'https://github.com/lascivaroma/priapeia' },
      { name: 'ancJewLitCTS', url: 'https://github.com/hlapin/ancJewLitCTS' },
      { name: 'canonical-latinLit', url: 'https://github.com/PerseusDL/canonical-latinLit' },
      { name: 'canonical-greekLit', url: 'https://github.com/PerseusDL/canonical-greekLit' },
      { name: 'canonical-farsiLit', url: 'https://github.com/PerseusDL/canonical-farsiLit' },
      { name: 'canonical-pdlpsci', url: 'https://github.com/PerseusDL/canonical-pdlpsci' },
    ]
  end
end
