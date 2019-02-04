# frozen_string_literal: true

require 'pruner/version'

module Pruner
  extend self

  APPLICATION_NAME = 'pruner'
  LOGGER_FORMATTER = lambda do |severity, time, prog, message|
    msg2hash(message).merge!(
      t: time.to_s,
      s: severity.to_s[0],
      p: escape(prog.to_s)
    ).to_json + "\n"
  end

  def msg2hash(message)
    case message
    when ::String
      { m: escape(message) }
    when ::Exception
      { m: escape("#{message.message} (#{message.class})") }
    when ::Hash
      message.dup
    else
      { m: escape(message.inspect) }
    end
  end

  def escape(string)
    string.tr("\n", '↲')
  end

  def env
    @env ||= (ENV['RACK_ENV'] || :development).to_sym
  end

  def root
    @root ||= File.expand_path('../..', __FILE__)
  end

  def logger
    @logger ||= begin
      logger = Logger.new(STDOUT)
      logger.progname = APPLICATION_NAME
      logger.formatter = LOGGER_FORMATTER
      logger
    end
  end

  def logger=(logger)
    @logger = logger
  end
end
