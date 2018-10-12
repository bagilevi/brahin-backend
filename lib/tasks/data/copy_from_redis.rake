puts "Loading..."

namespace :data do
  task :copy_from_redis_to_files => :environment do
    source_storage = RedisStorage.new
    target_storage = FileStorage.new

    source_storage.each do |path, part, payload|
      path = ResourcePath[path]
      puts "Migrating #{path}"
      target_storage.put(path, part, payload)
    end

    puts "Migration finished."
  end
end
