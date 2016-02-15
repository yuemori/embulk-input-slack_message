# Slack Message input plugin for Embulk

This plugin is embulk input from slack message.
Inspire of the [embulk-input-slack_history](https://github.com/yaggytter/embulk-input-slack-history/blob/master/lib/embulk/input/slack_history.rb)

## Overview

* **Plugin type**: input
* **Resume supported**: no
* **Cleanup supported**: no
* **Guess supported**: yes

## Advanced

### Complete use name

User name be id come from slack in message.

This plugin complete user name.

### Guess supported

This plugin guess supported.

Calculate between time from latest and oldest.

## Configuration

channel settings is references slack description ([here](https://api.slack.com/methods/channels.history))

- **channel**: channel settings (hash, required)
  - name: channel name (string, required)
  - type: channel type (string, required. this param is originated)
    - channel: public channel
    - group: private group
    - direct: direct message
    - multi_direct: multi direct message
  - latest: End of time range of messages to include in results. (string, default: now date)
  - oldest: Start of time range of messages to include in results. (string, default: 0)
  - count: Number of messages to return, between 1 and 1000 (long, default: 100)
  - inclusive: Include messages with latest or oldest timestamp in results (long, default: 0)
  - unreads: Include `unread_count_display` in the output? (long, default: 0)
- **token**: Slack API Token. Generate from [Slack Authentication](https://api.slack.com/web) (string, required)
- **repeat**: Adjustment of time when next config generation (mill seconds). (long, default: 0)

## Example

```yaml
in:
  type: slack_message
  channel:
    name: general
    type: channel
    latest: '2016-02-16 00:00:00'
    oldest: '2016-02-15 00:00:00'
    count: 100
    inclusive: 0
    unreads: 0
  token: 'aaaa-1111111111-2222222222-33333333333-bbbbbbbbbb'
  repeat: 0
  columns:
  - {index: 0, name: datetime, type: timestamp, format: null}
  - {index: 1, name: channel_id, type: string, format: null}
  - {index: 2, name: channel_name, type: string, format: null}
  - {index: 3, name: user_id, type: string, format: null}
  - {index: 4, name: user_name, type: string, format: null}
  - {index: 5, name: message, type: string, format: null}
```

## Build

```
$ rake
```
