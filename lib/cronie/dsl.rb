module Cronie
  # task "Check email", "0 */2 * * *" do
  #   # some process...
  # end
  module DSL
    # 定期実行するタスクを定義する
    def task(*args, &block)
      Cronie.add_task(*args, &block)
    end
  end
end
