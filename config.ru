# frozen_string_literal: true

STDOUT.sync = STDERR.sync = true

require_relative 'config/environment'

app = Rack::URLMap.new(
  '/' => Pruner::App,
)

run app

