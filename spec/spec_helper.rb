# frozen_string_literal: true

require 'rack/test'
require 'rspec'
require 'logger'
require 'support/vcr'

ENV['RACK_ENV'] = 'test'

require File.expand_path('../../config/environment.rb', __FILE__)

Pruner.logger = Logger.new('/dev/null')

RSpec.configure do |config|
  include Rack::Test::Methods
end
