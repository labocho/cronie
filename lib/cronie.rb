require "cronie/version"
require "time"

module Cronie
  class Error < StandardError; end
  autoload :DSL, "cronie/dsl"
  autoload :Schedule, "cronie/schedule"
  autoload :Task, "cronie/task"
  @queue = :cronie

  class << self
    # `time` should be either Time, String or Integer.
    # String will be passed by Time.parse.
    # Integer will be passed by Time.at
    def run(time)
      time = decode_time(time)
      tasks.each{|t| t.do(time) }
    end

    def add_task(*args, &block)
      tasks << Task.new(*args, &block)
    end

    def tasks
      @tasks ||= []
    end

    def load(path)
      sandbox = Object.new
      sandbox.send :extend, Cronie::DSL
      sandbox.instance_eval File.read(path)
    end

    # for Resque
    alias_method :perform, :run
    def run_async(time)
      Resque.enqueue(Cronie, encode_time(time))
    end

    private
    def encode_time(time)
      decode_time(time).utc.iso8601
    end

    def decode_time(time)
      case time
      when String
        Time.parse(time)
      when Integer
        Time.at(time)
      else
        time
      end
    end
  end
end
