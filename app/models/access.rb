class Access < Dry::Struct
  include Storage

  PART = 'access.yml'

  transform_keys(&:to_sym)
  attribute :path, ResourcePath
  attribute :authorizations, Types::Strict::Array.of(PathAuthorization)

  def self.find(path)
    path = ResourcePath[path]
    payload = storage.get(path, PART)
    if payload
      attrs = YAML.load(payload) || {}
      attrs.symbolize_keys!
      attrs[:path] = path
      attrs[:authorizations].map! { |a| PathAuthorization.new({ path: path }.merge(a.symbolize_keys)) }
      new(attrs)
    end
  end

  def self.find_or_initialize(path)
    path = ResourcePath[path]
    find(path) || new(path: path, authorizations: [])
  end

  def self.delete_all
    storage.delete_all_parts(PART)
  end

  def save!
    payload = attributes.except(:path)
    payload[:authorizations].map! { |a| a.attributes.except(:path).stringify_keys }
    payload.stringify_keys!
    payload = YAML.dump(payload)
    storage.put(path, PART, payload)
  end
end
