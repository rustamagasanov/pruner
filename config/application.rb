# frozen_string_literal: true

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
$:.unshift File.expand_path('../../lib', __FILE__)

require 'sinatra'
require 'pruner'
require 'pruner/api'
require 'pruner/app'
require 'pruner/upstream_fetcher'
require 'pruner/tree_pruner'
require 'pry' if Pruner.env == :development || Pruner.env == :test

configure { set :server, :puma }
