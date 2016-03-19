# encoding: UTF-8

require 'net/http'

module Fluent
  class SlackboardOutput < BufferedOutput
    Fluent::Plugin.register_output('slackboard', self)

    include SetTimeKeyMixin
    include SetTagKeyMixin

    config_set_default :include_time_key, true
    config_set_default :include_tag_key, true

    config_param :host,       :string, default: ""     # slackboard hostname
    config_param :port,       :string, default: ""     # slackboard port
    config_param :channel,    :string, default: ""     # slack channel
    config_param :fetch_key,  :string, default: ""     # fetched key
    config_param :username,   :string, default: ""     # slack username
    config_param :icon_emoji, :string, default: ""     # slack icon emoji
    config_param :parse,      :string, default: "full" # parse option for slack
    config_param :sync,       :bool,   default: false  # synchronous proxing

    def initialize
      super
    end

    def configure(conf)
      super

      if @host == ""
        raise Fluent::ConfigError.new "`host` is empty"
      end

      if @port == ""
        raise Fluent::ConfigError.new "`port` is empty"
      end

      @uri = URI.parse "http://" + @host + ":" + @port + "/notify-directly"

      if @channel == ""
        raise Fluent::ConfigError.new "`channel` is empty"
      end
      @channel = '#' + @channel unless @channel.start_with? '#'

      if @fetch_key == ""
        raise Fluent::ConfigError.new "`fetch_key` is empty"
      end

      if @username == ""
        @username = "slackboard"
      end

      if @icon_emoji == ""
        @icon_emoji = ":clipboard:"
      end
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def write(chunk)
      begin
        payloads = build_payloads chunk
        payloads.each { |payload|
          req = Net::HTTP::Post.new @uri.path
          req.body = payload.to_json
          res = Net::HTTP.start(@uri.host, @uri.port) { |http|
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
          :channel    => @channel,
          :username   => @username,
          :icon_emoji => @icon_emoji,
          :text       => record[@fetch_key],
          :parse      => @parse,
        }
        payload["sync"] = @sync
        payloads << payload
      end
      payloads
    end

  end
end
