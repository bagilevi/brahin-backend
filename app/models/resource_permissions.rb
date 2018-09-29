# The collection of all permission grants for a single resource.
class ResourcePermissions < Dry::Struct
  include Dry::Struct::Setters
  include Storage
  include AccessLevel

  PART = 'permissions.yml'

  transform_keys(&:to_sym)
  attribute :path, ResourcePath
  attribute :grants, Types::Strict::Array.of(PermissionGrant)

  def self.[](path)
    find_or_initialize(path)
  end

  def self.find(path)
    path = ResourcePath[path]
    payload = storage.get(path, PART)
    if payload
      attrs = YAML.load(payload) || {}
      attrs.symbolize_keys!
      attrs[:path] = path
      attrs[:grants].map! { |a| PermissionGrant.new({ path: path }.merge(a.symbolize_keys)) }
      new(attrs)
    end
  end

  def self.find_or_initialize(path)
    path = ResourcePath[path]
    self.find(path) || new(path: path, grants: [])
  end

  def self.delete_all
    storage.delete_all_parts(PART)
  end

  def save
    payload = attributes.except(:path)
    payload[:grants] = payload[:grants].map { |a| a.attributes.except(:path).stringify_keys }
    payload.stringify_keys!
    payload = YAML.dump(payload)
    storage.put(path, PART, payload)
  end

  def grant_to_public!(level)
    grant!(level, nil)
  end

  def grant!(level, token)
    return if grants.any? { |a| a.token == token && a.level == READ }
    grants << PermissionGrant.new(
      path: path,
      level: level,
      token: token,
    )
    save
  end
end
