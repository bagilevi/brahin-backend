require 'redis'

class RedisStorage
  def get(path)
    payload = redis.get(key(path))
    deserialize(payload) if payload.present?
  end

  def put(path, attributes)
    redis.set(key(path), serialize(attributes))
  end

  private

  def redis
    Redis.new
  end

  def key(path)
    "p:#{path}"
  end

  def serialize(attributes)
    JSON.generate(attributes)
  end

  def deserialize(payload)
    JSON.parse(payload)
  end
end
