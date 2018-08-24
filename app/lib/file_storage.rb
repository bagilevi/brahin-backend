# Storage backend preferred for development since it's easy to inspect.
#
class FileStorage
  def get(path)
    yamlpath, htmlpath = storage_paths(path)
    if File.exist?(yamlpath)
      attributes = YAML.load(File.read(yamlpath)).symbolize_keys
      if File.exist?(htmlpath)
        attributes[:body] = File.read(htmlpath)
      end
      attributes
    end
  end

  def put(path, attributes)
    yamlpath, htmlpath = storage_paths(path)
    FileUtils.mkdir_p(File.dirname(yamlpath))
    File.open(htmlpath, 'w') do |f|
      f.write(attributes[:body])
    end
    File.open(yamlpath, 'w') do |f|
      f.write(YAML.dump(attributes.except(:body).stringify_keys))
    end
  end

  private

  def storage_paths(path)
    base = root.join('data', sanitize_path(path)).to_s
    ["#{base}.yaml", "#{base}.html"]
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
