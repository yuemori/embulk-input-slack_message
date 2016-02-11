module Embulk
  module Input

    class SlackMessage < InputPlugin
      Plugin.register_input("slack_message", self)

      def self.transaction(config, &control)
        # configuration code:
        task = {
          'channels' => config.param('channels', :array),
          'latest' => config.param('latest', :string, default: Time.now.to_s),
          'oldest' => config.param('latest', :string, default: 0),
          'inclusive' => config.param('inclusive', :long, default: 0),
          'count' => config.param('count', :long, default: 100),
          'unreads' => config.param('unreads', :long, default: 0)
        }

        resume(task, self.columns, 1, &control)
      end

      def self.columns
        [
          Column.new(0, "messages", :string)
          # Column.new(0, "channel_id", :string),
          # Column.new(1, "channel_name", :string),
          # Column.new(2, "datetime", :timestamp),
          # Column.new(3, "user_id", :string),
          # Column.new(4, "user_name", :string),
          # Column.new(5, "message", :string)
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

        @options = {
          latest: Time.parse(task["latest"]),
          oldest: Time.parse(task["oldest"])
          inclusive: task['inclusive'],
          count: task['count'],
          unreads: task['unreads']
        }
      end

      def run
        @channels.each do |channel_name|
          channel_id = channels_list.find { |channel| channel['name'] == channel_name }['id']
          options = @options.merge(channel: channel_id)
          client.channels_history(options)['messages']
        end

        page_builder.add(["example-value", 1, 0.1])
        page_builder.add(["example-value", 2, 0.2])
        page_builder.finish

        task_report = {}
        return task_report
      end

      private

      def users_list
        @users_list ||= client.users_list["members"]
      end

      def channels_list
        @channels_list ||= client.channels_list["channels"]
      end

      def client
        Slack::Client.new token: @token
      end
    end
  end
end
