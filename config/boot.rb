$LOAD_PATH.unshift 'lib'

APPLICATION_ENV = ENV.fetch('APPLICATION_ENV', 'development')

require 'bundler'
Bundler.require(:default, APPLICATION_ENV)

# Ignore all uninitialized instance variable warnings
Warning.ignore(/instance variable @\w+ not initialized/)

Dotenv.load(".env.#{ APPLICATION_ENV }") if ['development', 'testing'].include? APPLICATION_ENV

# Needed by eg database config
require 'emerald/logger'

require 'config/emerald'

# Needs access to Emerald::Config
require 'emerald'

unless ENV['EMERALD_SKIP_MODELS'] == '1'
  # Has to be loaded after DB is ready.
  require 'emerald/models'
end

if Emerald::Config::Sentry.enabled?
  puts 'Configuring sentry integration.'

  Raven.configure do |config|
    config.dsn = Emerald::Config::Sentry::DSN
    config.release = Emerald::VERSION
    config.current_environment = APPLICATION_ENV
  end
else
  puts 'Skipping sentry integration configuration.'
end
