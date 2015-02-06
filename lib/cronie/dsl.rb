module Cronie
  module DSL
    # task "Check email", "0 */2 * * *" do
    #   # some process...
    # end
    def task(*args, &block)
      Cronie.add_task(*args, &block)
    end

    # pass to Time#getlocal
    def set_utc_offset(utc_offset)
      Time.now.getlocal(utc_offset) # validate
      Cronie.utc_offset = utc_offset
    end
  end
end
