# Storage backend preferred for development since it's easy to inspect.
#
class FileStorage
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

  def delete_all_parts(part)
    Dir[root.join('data', '**', part)].each do |fn|
      File.delete(fn)
    end
  end

  private

  def storage_path(path, part_type)
    path = ResourcePath[path]
    root.join('data', *path.elements, part_type).to_s
  end

  def sanitize_path(path)
    return 'home' if path.blank?
    path.split('/').compact.map(&method(:sanitize_path_element)).join('/')
  end

  def root
    Rails.root
  end

  def sanitize_path_element(s)
    s.parameterize
  end
end
