class Resource
  include Virtus.model

  attribute :id
  attribute :path
  attribute :editor
  attribute :editor_url
  attribute :body

  class << self
    attr_writer :storage

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

  def self.patch_by_path(params)
    instance = find_or_initialize_by_path(params[:path])
    instance.body = params[:body] if params.has_key?(:body)
    instance.save!
  end

  def self.find_or_initialize_by_path(path)
    find_by_path(path) || new(
      id: rand(10**20),
      path: path,
      editor: 'memonite-slate-editor-v1',
      editor_url: ENV.fetch('MEMONITE_SLATE_EDITOR_URL', '/modules/memonite-slate-editor-v1.js'),
      body: ''
    ).tap(&:init_plain_html_page)
  end

  def self.find_by_path(path)
    attributes = storage.get(path)
    new(attributes.merge(path: path)) if attributes.present?
  end

  def self.save(path, attributes)
    storage.put(path, attributes)
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
