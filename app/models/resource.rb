class Resource < Dry::Struct
  attribute :path, ResourcePath

  delegate :title, :title=, :editor, :editor=, :editor_url, :editor_url=, to: :_meta
  delegate :body, :body=, to: :_body
  delegate :make_publicly_readable, to: :permissions

  def self.[](path)
    new(path: ResourcePath[path])
  end

  def self.find_or_initialize_by_path(path)
    find_by_path(path) || initialize_by_path(path)
  end

  def self.initialize_by_path(path, attrs = {})
    Resource[path].tap { |r| r.init_default(attrs) }
  end

  def create!(params)
    init_default(params)
    save
  end

  def self.patch_by_path(params)
    resource = find_or_initialize_by_path(params[:path])
    resource.patch(params)
    resource.save
  end

  def self.find_by_path(path)
    path = ResourcePath[path]
    new(path: path)
  end

  def exists?
    _body.exists?
  end

  def _meta
    @_meta ||= ResourceMeta[path]
  end

  def _body
    @_body ||= ResourceBody[path]
  end

  def permissions
    @permissions ||= Access[path]
  end

  def patch(params)
    _body.body = params[:body] if params.has_key?(:body)
    _meta.title = params[:title] if params.has_key?(:title)
  end

  def update!(params)
    patch(params)
    save
  end

  def init_default(title: '', body: '')
    self.editor     = 'brahin-slate-editor'
    self.editor_url = ENV.fetch('BRAHIN_SLATE_EDITOR_URL', '/modules/brahin-slate-editor.js'),
    self.title      = title.presence
    self.body       = body.presence || "<h1>#{CGI.escapeHTML(title)}</h1><p></p>"
  end

  def save
    _body.save
    _meta.save
    self
  end

  def make_publicly_readable!
    permissions.grant_to_public!(AccessLevel::READ)
  end
end
