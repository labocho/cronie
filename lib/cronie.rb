require "cronie/version"
require "time"

module Cronie
  class Error < StandardError; end
  autoload :DSL, "cronie/dsl"
  autoload :Schedule, "cronie/schedule"
  autoload :Task, "cronie/task"
  @queue = :cronie

  class << self
    attr_accessor :utc_offset

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
      sandbox.instance_eval(File.read(path), path)
    end

    def run_async(time)
      warn "DEPRECATION WARNING: Cronie.run_async is deprecated. Use 'cronie/active_job'"
      Resque.enqueue(Cronie, encode_time(time))
    end

    def perform_now(*args)
      Cronie::ActiveJob.perform_now(*args)
    end
    alias_method :perform, :perform_now

    def perform_later(*args)
      Cronie::ActiveJob.perform_later(*args)
    end

    private
    def encode_time(time)
      decode_time(time).iso8601
    end

    def decode_time(time)
      t = case time
      when String
        Time.parse(time)
      when Integer
        Time.at(time)
      else
        time
      end
      utc_offset ? t.getlocal(utc_offset) : t
    end
  end
end
