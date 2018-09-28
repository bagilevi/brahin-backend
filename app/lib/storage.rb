module Storage
  def self.included(base)
    base.instance_eval do
      def storage
        Storage.storage
      end
    end
  end

  class << self
    def storage
      @storage ||= build_storage
    end

    def build_storage
      return FileStorage.new if ENV['STORAGE'] == 'file'
      return RedisStorage.new if ENV['STORAGE'] == 'redis'
      return FileStorage.new(File.expand_path('data')) if ENV['RAILS_ENV'].in?(['development'])
      return FileStorage.new(File.expand_path('tmp/testdata')) if ENV['RAILS_ENV'].in?(['test'])
      return FileStorage.new if ENV['RAILS_ENV'].in?(['development', 'test'])
      return RedisStorage.new
    end

    def reset
      storage.reset
    end
  end

  def storage
    self.class.storage
  end
end
