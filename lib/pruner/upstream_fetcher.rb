# frozen_string_literal: true

require 'http'

module Pruner
  module UpstreamFetcher
    extend self
    include Pruner::Errors

    UPSTREAM_BASE_URL = ENV['UPSTREAM_BASE_URL']
    UPSTREAM_FETCH_ATTEMPTS = ENV['UPSTREAM_FETCH_ATTEMPTS'].to_i
    UPSTREAM_FETCH_RETRY_DELAY = ENV['UPSTREAM_FETCH_RETRY_DELAY'].to_f

    def call(upstream_name)
      raise ArgumentError, "'upstream_name' must be a String" unless upstream_name.is_a?(String)
      UPSTREAM_FETCH_ATTEMPTS.times do
        response = HTTP.get("#{UPSTREAM_BASE_URL}#{upstream_name}")
        case response.code
        when 200; return JSON.parse(response.body)
        when 404; raise NotFound, "Failed to find an upstream '#{upstream_name}'"
        when 500; sleep(UPSTREAM_FETCH_RETRY_DELAY)
        end
      end
      raise StandardError, "Failed to fetch an upstream after " \
        "#{UPSTREAM_FETCH_ATTEMPTS} attempts"
    end
  end
end
