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
  host       host
  port       port
  channel    random
  fetch_key  message
  # optional
  username   slackboard
  icon_emoji :clipboard:
  parse      true
  sync       false
</match>
```

## License

MIT License
