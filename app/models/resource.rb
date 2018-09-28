class Resource
  include Virtus.model

  attribute :id
  attribute :path
  attribute :title
  attribute :editor
  attribute :editor_url
  attribute :body

  include Storage
  BODY_PART = 'content.html'
  META_PART = 'meta.yml'

  def self.find_or_initialize_by_path(path)
    find_by_path(path) || initialize_by_path(path)
  end

  def self.initialize_by_path(path, opts = {})
    new(
      id: rand(10**20),
      path: path,
      editor: 'brahin-slate-editor',
      editor_url: ENV.fetch('BRAHIN_SLATE_EDITOR_URL', '/modules/brahin-slate-editor.js'),
      body: ''
    ).tap do |resource|
      resource.init_plain_html_page(opts)
    end
  end

  def self.create(params)
    initialize_by_path(params[:path], params.except(:path))
  end

  def self.patch_by_path(params)
    resource = find_or_initialize_by_path(params[:path])
    resource.patch(params)
    resource.save!
  end

  def self.find_by_path(path)
    meta_payload = storage.get(path, META_PART)
    body = storage.get(path, BODY_PART)
    return nil if meta_payload.nil? && body.nil?

    attributes = meta_payload.present? ? YAML.load(meta_payload).symbolize_keys : {}
    attributes[:body] = body
    new(attributes.merge(path: path))
  end

  def self.save(path, attributes)
    storage.put(path, META_PART, YAML.dump(attributes.except(:body).stringify_keys))
    storage.put(path, BODY_PART, attributes[:body])
  end

  def self.digest(path)
    Digest::MD5.hexdigest(path)
  end

  def patch(params)
    self.body = params[:body] if params.has_key?(:body)
    self.title = params[:title] if params.has_key?(:title)
  end

  def init_plain_html_page(title: '', body: '')
    self.body = body.presence || "<h1>#{CGI.escapeHTML(title)}</h1><p></p>"
  end

  def save!
    self.class.save(path, attributes.except(:path))
  end
end
