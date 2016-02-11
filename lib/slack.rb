require 'active_support'
require 'active_support/core_ext'
require 'rest-client'
require 'json'
require 'slack/client'

module Slack
  class << self
    attr_accessor :token
    delegate :channels, :messages, :users, :options=, to: :client

    def configure(&block)
      yield configuration
    end

    private

    def client
      @client = Slack::Client.new(token)
    end
  end
end
