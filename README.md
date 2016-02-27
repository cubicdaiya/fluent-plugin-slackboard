# fluent-plugin-slackboard

fluent-plugin-slackboard proxies a message to [slackboard](https://github.com/cubicdaiya/slackboard).

<!--
## Installation

Install it using gem:

```
gem install fluent-plugin-slackboard
```
-->

## Usage

```
<match>
  type slackboard
  # required
  slackboard_host       host
  slackboard_port       port
  slackboard_channel    random
  slackboard_fetch_key  message
  # optional
  slackboard_username   slackboard
  slackboard_icon_emoji :clipboard:
  slackboard_parse      true
  slackboard_sync       false
</match>
```

## License

MIT License
