# coding: utf-8

require 'config/boot'

require 'resque/server'
require 'resque/scheduler/server'
require 'resque-job-stats/server'

url_map = {
  '/' => Emerald::Web::API
}

resque_web_path = Emerald::Config::Resque::WEB_PATH
url_map[resque_web_path] = Resque::Server.new if resque_web_path

if Emerald::Config::Sentry.enabled?
  puts 'Enabling rack sentry integration.'
  use Raven::Rack
else
  puts 'Skipping rack sentry integration.'
end

run Rack::URLMap.new(url_map)
