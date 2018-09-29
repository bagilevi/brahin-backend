# Storage backend preferred for development since it's easy to inspect.
#
class FileStorage
  def initialize(root = nil)
    @root = Pathname.new(root || File.expand_path('data'))
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
  end

  def del(path, part)
    sp = storage_path(path, part)
    File.delete(sp) if File.exists?(sp)
  end

  def delete_all_parts(part)
    Dir[root.join('**', part)].each do |fn|
      File.delete(fn)
    end
  end

  def reset
    FileUtils.rm_rf(root.to_s)
  end

  private

  attr_reader :root

  def storage_path(path, part_type)
    path = ResourcePath[path]
    root.join(*path.elements, part_type).to_s
  end
end
