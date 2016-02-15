require 'slack'

module Embulk
  module Input
    class SlackMessage < InputPlugin
      Plugin.register_input("slack_message", self)

      def self.transaction(config, &control)
        task = {
          'channel' => config.param('channel', :hash),
          'token' => config.param('token', :string),
          'repeat_at' => config.param('repeat_at', :long, default: 0)
        }

        yield(task, columns, 1)

        channel = task['channel']
        repeat_at = task['repeat_at']
        latest = channel['latest'] ? Time.parse(channel['latest']).to_f : Time.now.to_f
        oldest = channel['oldest'] ? Time.parse(channel['oldest']).to_f : 0

        if repeat_at.zero?
          time_diff = latest.to_i - oldest.to_i
          channel = { oldest: Time.at(latest), latest: Time.at(latest + time_diff) }
        else
          channel = { oldest: oldest + repeat_at, latest: latest + repeat_at }
        end

        { channel: channel }
      end

      def self.columns
        [
          Column.new(0, "datetime", :timestamp),
          Column.new(1, "channel_id", :string),
          Column.new(2, "channel_name", :string),
          Column.new(3, "user_id", :string),
          Column.new(4, "user_name", :string),
          Column.new(5, "message", :string)
        ]
      end

      def self.guess(config)
        channels = [
          {
            name: 'general',
            type: 'channel',
            latest: Time.now.strftime('%F %T'),
            oldest: 0,
            count: 100,
            inclusive: 0,
            unreads: 0
          }
        ]
        { channel: channels.first, token: 'SLACK_API_TOKEN', repeat: 0, columns: Embulk::Schema.new(self.columns) }
      end

      def init
        @channel = task["channel"]

        token = task['token']
        raise StandardError.new, 'slack token is not found' unless token

        Slack.token = token
      end

      def run
        latest = @channel['latest'] ? Time.parse(@channel['latest']).to_f : Time.now.to_f
        oldest = @channel['oldest'] ? Time.parse(@channel['oldest']).to_f : 0
        inclusive = @channel['inclusive'] || 0
        count = @channel['count'] || 100
        unreads = @channel['unreads'] || 0

        options = {
          latest: latest,
          oldest: oldest,
          inclusive: inclusive,
          count: count,
          unreads: unreads
        }

        p @channel

        Slack.messages(@channel['name'], @channel['type'], options).each do |message|
          page_builder.add message
        end

        page_builder.finish

        task_report = {}
        return task_report
      end
    end
  end
end
