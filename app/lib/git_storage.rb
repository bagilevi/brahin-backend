# Storage backend that saves into files in a git working directory, and
# syncs it to an origin.
#
class GitStorage
  delegate :redis, to: :RedisConnection

  def initialize(root = GitSync.work_dir)
    @root = Pathname.new(root)
  end

  def get(path, part)
    sp = storage_path(path, part)
    if File.exist?(sp)
      File.read(sp)
    end
  end

  def put(path, part, payload)
    sp = storage_path(path, part)
    FileUtils.mkdir_p(File.dirname(sp))
    File.open(sp, 'w') do |f|
      f.write(payload)
    end
    GitSync.notify_save
  end

  def del(path, part)
    sp = storage_path(path, part)
    File.delete(sp) if File.exists?(sp)
    GitSync.notify_save
  end

  def delete_all_parts(part)
    Dir[root.join('**', part)].each do |fn|
      File.delete(fn)
    end
    GitSync.notify_save
  end

  def put_blob(payload, original_filename)
    file_path, web_path = blob_storage_path_from_content(payload, original_filename)
    FileUtils.mkdir_p(File.dirname(file_path))
    File.open(file_path, 'wb') do |file|
      file.write(payload)
    end
    GitSync.notify_save
    web_path
  end

  def get_blob(name)
    File.read(blob_storage_path_from_name(name))
  end

  # TODO: del_blob

  def reset
    FileUtils.rm_rf(root.to_s)
  end

  private

  attr_reader :root

  def storage_path(path, part_type)
    path = ResourcePath[path]
    root.join(*path.elements, part_type).to_s
  end

  def blob_storage_path_from_content(payload, original_filename)
    digest = Digest::SHA1.hexdigest(payload)
    ext = File.extname(original_filename)
    path_elements = ['_blobs', "#{digest}#{ext}"]
    [root.join(*path_elements), "/#{path_elements.join('/')}"]
  end

  def blob_storage_path_from_name(name)
    root.join('_blobs', name)
  end
end
