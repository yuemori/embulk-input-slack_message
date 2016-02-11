module Slack
  class Client
    attr_reader :options, :token

    def initialize(token, options)
      @token = token
      @options = options
    end

    def channels
      @channels ||= JSON.parse(get('channels.list', { exclude_archived: 1 }))['channels']
    end

    def messages(name)
      if name[0] == '#'
        channel = channels.find { |_channel| _channel['name'] == name.delete('#') }
      else
        channel = groups.find { |group| group['name'] == name }
      end
      messages = JSON.parse(get('channels.history', options.merge(channel: channel['id'])))['messages']
      messages.select { |message| message['type'] == 'message' && message['subtype'].nil? }.map do |message|
        [
          channel['id'],
          channel['name'],
          Time.at(message['ts'].to_i),
          message['user'],
          user(message['user'])['name'],
          message['text']
        ]
      end
    end

    def user(name)
      users.find { |user| user['id'] == name }
    end

    def users
      @users ||= JSON.parse(get('users.list', { presence: 0 }))['members']
    end

    def groups
      @groups ||= JSON.parse(get('groups.list', { presence: 0 }))['members']
    end

    def get(api, options)
      RestClient.get("https://slack.com/api/#{api}", { params: options.merge(token: token) })
    end
  end
end
