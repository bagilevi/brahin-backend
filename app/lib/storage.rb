module Storage
  def self.included(base)
    base.instance_eval do
      cattr_writer :storage

      def storage
        @storage ||= build_storage
      end

      def build_storage
        return FileStorage.new if ENV['STORAGE'] == 'file'
        return RedisStorage.new if ENV['STORAGE'] == 'redis'
        return FileStorage.new if ENV['RAILS_ENV'].in?(['development', 'test'])
        return RedisStorage.new
      end
    end
  end

  def storage
    self.class.storage
  end
end
