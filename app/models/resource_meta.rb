class ResourceMeta < Dry::Struct
  include Dry::Struct::Setters
  include Storage
  PART = 'meta.yml'.freeze

  attribute :path, ResourcePath
  attribute :title, Types::Coercible::String.optional.default(nil)
  attribute :editor, Types::Coercible::String.optional.default(nil)
  attribute :editor_url, Types::Coercible::String.optional.default(nil)

  def self.[](path)
    path = ResourcePath[path]
    payload = storage.get(path, PART)
    if payload
      attrs = YAML.load(payload) || {}
      attrs.symbolize_keys!
      new({ path: path }.merge(attrs))
    else
      new(path: path)
    end
  end

  def self.find_or_initialize(path)
    path = ResourcePath[path]
    find(path) || new
  end

  def save
    payload = YAML.dump(attributes.except(:path).stringify_keys)
    storage.put(path, PART, payload)
  end
end
