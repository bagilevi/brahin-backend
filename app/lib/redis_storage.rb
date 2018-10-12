require 'redis'

class RedisStorage
  delegate :redis, to: :RedisConnection
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

  def each
    redis.keys("resource:*").each do |k|
      path, part = k.split(':')[1..2]
      payload = get(path, part)
      path = path.sub(/^root\//, '/').sub(/^root$/, '/')
      yield path, part, payload
    end
  end

  private

  def key(path, part)
    path = path.to_key if path.respond_to?(:to_key)
    "resource:#{path}:#{part}"
  end
end
