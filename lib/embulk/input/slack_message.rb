require 'slack'

module Embulk
  module Input
    class SlackMessage < InputPlugin
      Plugin.register_input("slack_message", self)

      def self.transaction(config, &control)
        task = {
          'channels' => config.param('channels', :array),
          'token' => config.param('token', :string)
        }

        resume(task, self.columns, 1, &control)
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

      def self.resume(task, columns, count, &control)
        task_reports = yield(task, columns, count)

        {oldest: Time.now.to_s}
      end

      def self.guess(config)
        { columns: Embulk::Schema.new(self.columns) }
      end

      def init
        @channels = task["channels"]

        token = task['token'] || ENV['SLACK_TOKEN']
        raise StandardError.new, 'slack token is not found' unless token

        Slack.token = token
      end

      def run
        @channels.each do |channel|
          latest = channel['latest'] ? Time.parse(channel['latest']).to_f : Time.now.to_f
          oldest = channel['oldest'] ? Time.parse(channel['oldest']).to_f : 0
          inclusive = channel['inclusive'] || 0
          count = channel['count'] || 100
          unreads = channel['unreads'] || 0

          options = {
            latest: latest,
            oldest: oldest,
            inclusive: inclusive,
            count: count,
            unreads: unreads
          }

          Slack.messages(channel['name'], channel['type'], options).each do |message|
            page_builder.add message
          end
        end

        page_builder.finish

        task_report = {}
        return task_report
      end
    end
  end
end
