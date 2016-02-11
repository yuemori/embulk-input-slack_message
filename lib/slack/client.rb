module Slack
  class Client
    attr_reader :options, :token

    def initialize(token)
      @token = token
    end

    def messages(name, type, options)
      channel = case type
      when 'channel' then channels.find { |item| item['name'] == name }
      when 'group' then groups.find { |item| item['name'] == name }
      when 'direct' then im.find { |item| item['user'] == name }
      when 'multi_direct' then mpim.find { |item| item['name'] == name }
      end
      messages = JSON.parse(get('channels.history', options.merge(channel: channel['id'])))['messages']
      messages.select { |message| message['type'] == 'message' && message['subtype'].nil? }.map do |message|
        [
          Time.at(message['ts'].to_i),
          channel['id'],
          channel['name'],
          message['user'],
          user_by_id(message['user'])['name'],
          filter_message(message['text'])
        ]
      end.reverse
    end

    def filter_message(text)
      text = text.dup
      scan = text.scan(/\<@[0-9A-Z]+\>/)
      return text unless scan

      scan.each do |pattern|
        user_id = pattern.match(/<@(?<user_id>.*)>/)[:user_id]
        text.gsub!(/#{pattern}/, "@#{user_by_id(user_id)['name']}")
      end
      text
    end

    def user_by_id(id)
      users.find { |user| user['id'] == id }
    end

    def user_by_name(name)
      users.find { |user| user['name'] == name }
    end

    def users
      @users ||= JSON.parse(get('users.list', { presence: 0 }))['members']
    end

    def channels
      @channels ||= JSON.parse(get('channels.list', { exclude_archived: 1 }))['channels']
    end

    def groups
      @groups ||= JSON.parse(get('groups.list', { exclude_archived: 1 }))['groups']
    end

    def ims
      @ims ||= JSON.parse(get('im.list'))['ims']
    end

    def mpim
      @mpims ||= JSON.parse(get('mpim.list'))['groups']
    end

    def get(api, options = {})
      RestClient.get("https://slack.com/api/#{api}", { params: options.merge(token: token) })
    end
  end
end
