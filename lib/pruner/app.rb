# frozen_string_literal: true

module Pruner
  class App < Sinatra::Base
    include Pruner::Errors

    API_CONTENT_TYPE = 'application/json'

    error NotFound do
      logger.info m: env['sinatra.error'].message
      content_type API_CONTENT_TYPE
      [404, { message: 'Not found' }.to_json]
    end

    error InvalidParameters do
      logger.info m: env['sinatra.error'].message
      content_type API_CONTENT_TYPE
      [400, { message: 'Invalid parameters' }.to_json]
    end

    error StandardError do
      logger.error m: env['sinatra.error'].message, backtrace: $!.backtrace
      content_type API_CONTENT_TYPE
      [500, { message: 'Internal Server Error' }.to_json]
    end

    def logger
      Pruner.logger
    end

    disable :dump_errors
    register Pruner::Api::Tree
  end
end

