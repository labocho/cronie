require "cronie/version"

module Cronie
  class Error < StandardError; end
  autoload :DSL, "cronie/dsl"
  autoload :Schedule, "cronie/schedule"
  autoload :Task, "cronie/task"

  class << self
    def run(time)
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

    # ===== Resque 対応ここから =====
    alias_method :perform, :run
    @queue = :cronie

    def run_async(time)
      Resque.enqueue(Cronie, time)
    end
    # ===== Resque 対応ここまで =====
  end
end
