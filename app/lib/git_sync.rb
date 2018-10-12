module GitSync
  extend self

  SAVE_CHANNEL = 'gitsync:save'.freeze
  PULL_CHANNEL = 'gitsync:pull'.freeze

  WORK_DIR = (ENV['GIT_REPO_DIR'] || File.expand_path('data')).freeze

  delegate :redis, to: RedisConnection

  def notify_save
    redis.publish(SAVE_CHANNEL, '1')
  end

  def notify_pull
    redis.publish(PULL_CHANNEL, '1')
  end

  def work_dir
    WORK_DIR
  end

  class << self
    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end
