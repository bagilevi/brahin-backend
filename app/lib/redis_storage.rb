require 'redis'

class RedisStorage
  def get(path, part)
    redis.get(key(path, part))
  end

  def put(path, part, payload)
    redis.set(key(path, part), payload)
  end

  def del(path, part)
    redis.del(key(path, part))
  end

  def delete_all_parts(part)
    keys = redis.keys("*:#{part}")
    redis.pipelined do
      keys.each do |key|
        redis.del(key)
      end
    end
  end

  def reset
    redis.flushdb
  end

  private

  def redis
    $redis || Redis.new
  end

  def key(path, part)
    "resource:#{path.to_key}:#{part}"
  end
end
