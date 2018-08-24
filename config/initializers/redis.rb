if ENV["REDIS_URL"]
  $redis = Redis.new(url: ENV["REDIS_URL"])
elsif ENV["REDISCLOUD_URL"]
  $redis = Redis.new(url: ENV["REDISCLOUD_URL"])
end
