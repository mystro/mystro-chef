class ChefWorker
  @queue = :default

  class << self
    def perform(options={ })
      Jobs::Chef::Roles.create!.enqueue
    rescue => e
      logger.error e.message
      logger.error e
    end
  end
end
