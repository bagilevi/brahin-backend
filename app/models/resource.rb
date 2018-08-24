class Resource
  include Virtus.model

  attribute :id
  attribute :path
  attribute :editor
  attribute :editor_url
  attribute :body

  def self.patch_by_path(params)
    instance = find_or_initialize_by_path(params[:path])
    instance.body = params[:body] if params.has_key?(:body)
    instance.save!
  end

  def self.find_or_initialize_by_path(path)
    find_by_path(path) || new(
      id: rand(10**20),
      path: path,
      editor: 'memonite-slate-v0.0.1',
      editor_url: 'http://localhost:3573/static/js/bundle.js',
      body: ''
    ).tap(&:init_plain_html_page)
  end

  def self.find_by_path(path)
    filepath = storage_path(path)
    if File.exist?(filepath + '.yaml')
      attributes = YAML.load(File.read(filepath + '.yaml')).symbolize_keys.merge(path: path)
      if File.exist?(filepath + '.html')
        attributes[:body] = File.read(filepath + '.html')
      end
      new(attributes)
    end
  end

  def self.save(path, attributes)
    filepath = storage_path(path)
    FileUtils.mkdir_p(File.dirname(filepath))
    File.open(filepath + '.html', 'w') do |f|
      f.write(attributes[:body])
    end
    File.open(filepath + '.yaml', 'w') do |f|
      f.write(YAML.dump(attributes.except(:body).stringify_keys))
    end
  end

  def self.storage_path(path)
    Rails.root.join('data', sanitize_path(path)).to_s
  end

  def self.sanitize_path(path)
    return 'home' if path.blank?
    path.split('/').compact.map(&method(:sanitize_path_element)).join('/')
  end

  def self.sanitize_path_element(s)
    s.parameterize
  end

  def self.digest(path)
    Digest::MD5.hexdigest(path)
  end

  def init_plain_html_page
    self.body = '<h1>Untitled</h1><p>Lorem ipsum...</p>'
  end

  def save!
    self.class.save(path, attributes.except(:path))
  end
end
