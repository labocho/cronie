module Cronie
  class Task
    attr_accessor :name, :schedule

    # args: [name, schedule_string] || [schedule_string] || []
    def initialize(*args, &proc)
      schedule_string = args.pop || "* * * * *"
      name = args.first
      @schedule = Cronie::Schedule.parse(schedule_string)
      @name, @proc = name, proc
    end

    def do(time)
      @proc.call(time) if schedule =~ time
    end
  end
end
