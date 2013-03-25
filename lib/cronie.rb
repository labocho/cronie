require "cronie/version"

module Cronie
  class Error < StandardError; end
  autoload :DSL, "cronie/dsl"
  autoload :Schedule, "cronie/schedule"
  autoload :Task, "cronie/task"
  @queue = :cronie

  class << self
    def run(time)
      time = time.is_a?(String) ? Time.parse(time) : time
      tasks.each{|t| t.do(time)}
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
      Resque.enqueue(Cronie, time)
    end
  end
end
