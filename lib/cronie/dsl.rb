module Cronie
  # extend Cronie::DSL # or include on toplevel
  # task "Check email", "0 */2 * * *" do
  #   # some process...
  # end
  module DSL
    # 定期実行するタスクを定義する
    def task(*args, &block)
      Cronie.tasks << Task.new(*args, &block)
    end
  end
end
