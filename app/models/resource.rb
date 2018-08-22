class Resource
  include Virtus.model

  attribute :id
  attribute :path
  attribute :editor
  attribute :body

  def self.patch_by_path(params)
    instance = find_or_initialize_by_path(params[:path])
    instance.body = params[:body] if params.has_key?(:body)
    instance.save!
  end

  def self.find_or_initialize_by_path(path)
    find_by_path(path) || new(id: rand(10**20), path: path, editor: 'first-v0.0.1', body: '').tap(&:init_plain_html_page)
  end

  def self.find_by_path(path)
    filepath = storage_path(path)
    if File.exist?(filepath)
      new(JSON.parse(File.read(filepath)).merge(path: path))
    end
  end

  def self.save(path, attributes)
    filepath = storage_path(path)
    FileUtils.mkdir_p(File.dirname(filepath))
    File.open(filepath, 'w') do |f|
      f.write(JSON.generate(attributes))
    end
  end

  def self.storage_path(path)
    Rails.root.join('data', digest(path))
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
