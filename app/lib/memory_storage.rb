class MemoryStorage
  def initialize
    reset
  end

  def get(path, part)
    @store[key(path, part)]
  end

  def put(path, part, payload)
    @store[key(path, part)] = payload
  end

  def del(path, part)
    @store.delete(key(path, part))
  end

  def delete_all_parts(part)
    @store.delete_if { |key, value| key.end_with?(":#{part}")}
  end

  def reset
    @store = {}
  end

  private

  def key(path, part)
    "resource:#{path.to_key}:#{part}"
  end
end
