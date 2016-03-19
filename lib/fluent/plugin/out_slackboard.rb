# encoding: UTF-8

require 'net/http'

module Fluent
  class SlackboardOutput < BufferedOutput
    Fluent::Plugin.register_output('slackboard', self)

    include SetTimeKeyMixin
    include SetTagKeyMixin

    config_set_default :include_time_key, true
    config_set_default :include_tag_key, true

    config_param :slackboard_host,       :string, default: ""     # slackboard hostname
    config_param :slackboard_port,       :string, default: ""     # slackboard port
    config_param :slackboard_channel,    :string, default: ""     # slack channel
    config_param :slackboard_fetch_key,  :string, default: ""     # fetched key
    config_param :slackboard_username,   :string, default: ""     # slack username
    config_param :slackboard_icon_emoji, :string, default: ""     # slack icon emoji
    config_param :slackboard_parse,      :string, default: "full" # parse option for slack
    config_param :slackboard_sync,       :bool,   default: false  # synchronous proxing

    def initialize
      super
    end

    def configure(conf)
      super

      if @slackboard_host == ""
        raise Fluent::ConfigError.new "`slackboard_host` is empty"
      end

      if @slackboard_port == ""
        raise Fluent::ConfigError.new "`slackboard_port` is empty"
      end

      @slackboard_uri = URI.parse "http://" + @slackboard_host + ":" + @slackboard_port + "/notify-directly"

      if @slackboard_channel == ""
        raise Fluent::ConfigError.new "`slackboard_channel` is empty"
      end
      @slackboard_channel = '#' + @slackboard_channel unless @slackboard_channel.start_with? '#'

      if @slackboard_fetch_key == ""
        raise Fluent::ConfigError.new "`slackboard_fetch_key` is empty"
      end

      if @slackboard_username == ""
        @slackboard_username = "slackboard"
      end

      if @slackboard_icon_emoji == ""
        @slackboard_icon_emoji = ":clipboard:"
      end
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def write(chunk)
      begin
        payloads = build_payloads chunk
        payloads.each { |payload|
          req = Net::HTTP::Post.new @slackboard_uri.path
          req.body = payload.to_json
          res = Net::HTTP.start(@slackboard_uri.host, @slackboard_uri.port) { |http|
            http.request req
          }
        }
      rescue Timeout::Error => e
        log.warn "out_slackboard:", :error => e.to_s, :error_class => e.class.to_s
        raise e
      rescue => e
        log.error "out_slackboard:", :error => e.to_s, :error_class => e.class.to_s
        log.warn_backtrace e.backtrace
      end
    end

    private

    def build_payloads(chunk)
      payloads = []
      chunk.msgpack_each do |tag, time, record|
        payload = {}
        payload["payload"] = {
          :channel    => @slackboard_channel,
          :username   => @slackboard_username,
          :icon_emoji => @slackboard_icon_emoji,
          :text       => record[@slackboard_fetch_key],
          :parse      => @slackboard_parse,
        }
        payload["sync"] = @slackboard_sync
        payloads << payload
      end
      payloads
    end

  end
end
