require 'active_support'
require 'active_support/core_ext'
require 'rest-client'
require 'json'
require 'slack/client'

module Slack
  class << self
    delegate :channels, :messages, :users, :options=, to: :client
    delegate :token, :options, to: :configuration

    def configure(&block)
      yield configuration
    end

    def configuration
      @configuration ||= Struct.new(:token, :options).new
    end

    private

    def client
      @client = Slack::Client.new(token, options)
    end
  end
end
