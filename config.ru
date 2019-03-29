# coding: utf-8

require 'config/boot'

url_map = {
  '/' => Emerald::Web::API
}

if Emerald::Config::Sentry.enabled?
  puts 'Enabling rack sentry integration.'
  use Raven::Rack
else
  puts 'Skipping rack sentry integration.'
end

run Rack::URLMap.new(url_map)
