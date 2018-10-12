# Single entry point to get a redis connection.
module RedisConnection
  class << self
    def redis
      $redis ||= url.present? ? Redis.new(url: url) : Redis.new
    end

    def url
      if ENV["REDIS_URL"]
        ENV["REDIS_URL"]
      elsif ENV["REDISCLOUD_URL"]
        ENV["REDISCLOUD_URL"]
      end
    end
  end
end
