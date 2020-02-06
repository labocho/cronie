require "cronie"

module Cronie
  class ActiveJob < ::ApplicationJob
    queue_as :cronie

    def perform(time)
      Cronie.run(time)
    end
  end
end
