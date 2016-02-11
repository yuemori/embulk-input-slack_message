require 'slack'

module Embulk
  module Input
    class SlackMessage < InputPlugin
      Plugin.register_input("slack_message", self)

      def self.transaction(config, &control)
        task = {
          'channels' => config.param('channels', :array),
          'token' => config.param('token', :string, default: nil),
          'latest' => config.param('latest', :string, default: Time.now.to_s),
          'oldest' => config.param('oldest', :string, default: 0),
          'inclusive' => config.param('inclusive', :string, default: 0),
          'count' => config.param('count', :string, default: 100),
          'unreads' => config.param('unreads', :string, default: 0)
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

        Slack.configure do |config|
          config.token = token
          config.options = {
            latest: Time.parse(task["latest"]).to_f,
            oldest: Time.parse(task["oldest"]).to_f,
            inclusive: task['inclusive'],
            count: task['count'],
            unreads: task['unreads']
          }
        end
      end

      def run
        @channels.each do |channel_name|
          Slack.messages(channel_name).each do |message|
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
