# Represents an permission grant for a single path, for a single token.
class PermissionGrant < Dry::Struct
  include AccessLevel
  include Storage

  transform_keys(&:to_sym)
  attribute :path, ResourcePath
  attribute :level, Types::Strict::Integer
  attribute :token, Types::Strict::String.optional

  def self.get_authorization(path, tokens)
    tokens = Array(tokens)
    path = ResourcePath[path]
    grants = path.with_ancestors.flat_map { |iter_path| ResourcePermissions.find(iter_path)&.grants }.compact

    if grants.none? { |r| r.level == ADMIN } && tokens.size == 1
      # Nobody owns this site => first visitor takes ownership
      grant = create!(path: '/', level: ADMIN, token: tokens.first)
      grants = [grant]
    end

    return Authorization.new(grants, path, tokens)
  end

  def self.find_highest_path(path, token)
    path = ResourcePath[path]
    grants = path.with_ancestors.flat_map { |iter_path| ResourcePermissions.find(iter_path)&.grants }.compact
    grants.select! { |grant| grant.token == token }
    grants.map(&:path).min_by(&:depth)
  end

  def self.update_all_for_path(path, grants)
    path = ResourcePath[path]
    permissions = ResourcePermissions[path]
    permissions.grants =
      grants.map do |attrs|
        PermissionGrant.new(
          path: path,
          token: attrs[:token].presence,
          level: attrs[:level]&.to_i,
        )
      end
    permissions.save
  end

  def self.delete_all
    ResourcePermissions.delete_all
  end

  def self.create!(path:, level:, token:)
    path = ResourcePath[path]

    # storage.put(path, { level: level, token: token })
    access = ResourcePermissions.find_or_initialize(path)
    grant = PermissionGrant.new(path: path, level: level, token: token)
    access.grants << grant
    access.save

    grant
  end
end
