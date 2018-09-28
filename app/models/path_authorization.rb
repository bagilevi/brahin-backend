class PathAuthorization < Dry::Struct
  include AccessLevel
  include Storage

  transform_keys(&:to_sym)
  attribute :path, ResourcePath
  attribute :level, Types::Strict::Integer
  attribute :token, Types::Strict::String.optional

  def self.get(path, token)
    path = ResourcePath[path]
    records = path.with_ancestors.flat_map { |iter_path| Access.find(iter_path)&.authorizations }.compact

    if records.none? { |r| r.level == ADMIN }
      # Nobody owns this site => first visitor takes ownership
      record = create!(path: '/', level: ADMIN, token: token)
      records = [record]
    end

    return Authorization.new(records, path, token)
  end

  def self.find_highest_path(path, token)
    path = ResourcePath[path]
    records = path.with_ancestors.flat_map { |iter_path| Access.find(iter_path)&.authorizations }.compact
    records.select! { |entry| entry.token == token }
    records.map(&:path).min_by(&:depth)
  end

  def self.update_all_for_path(path, entries)
    path = ResourcePath[path]
    permissions = Access[path]
    permissions.authorizations =
      entries.map do |attrs|
        PathAuthorization.new(
          path: path,
          token: attrs[:token].presence,
          level: attrs[:level]&.to_i,
        )
      end
    permissions.save
  end

  def self.delete_all
    Access.delete_all
  end

  def self.create!(path:, level:, token:)
    path = ResourcePath[path]

    # storage.put(path, { level: level, token: token })
    access = Access.find_or_initialize(path)
    record = PathAuthorization.new(path: path, level: level, token: token)
    access.authorizations << record
    access.save

    record
  end

  class AuthorizationBase
    include AccessLevel

    def can_create?; can? CREATE end
    def can_read?;   can? READ   end
    def can_write?;  can? WRITE  end
    def can_admin?;  can? ADMIN  end
  end

  class Authorization < AuthorizationBase
    def initialize(records, path, token)
      # pp records
      @records = records
      container_path = @records.select { |r| r.level == ADMIN }.map(&:path).max_by(&:depth)
      @records.reject! { |r| r.path.nests?(container_path) }

      @path = path
      @token = token
    end

    def can?(wanted_level)
      matching_records = @records.select { |r| r.token.nil? || r.token == @token }
      other_records = @records - matching_records

      authorizing_record = matching_records.find { |r| allows?(wanted_level, r.level) }

      return false if authorizing_record.blank?

      if wanted_level == CREATE
        # Can only create if no-one else has created a conflicting path
        # E.g. anyone can create under /users
        # - another user creates /users/joe
        # - current user cannot create /users/joe/foo
        # `authorizing_record` for /users with CREATE level is found for the current user,
        # but another user already has rights /users/joe which starts with /users/
        return false if other_records.any? { |r| r.path.nested_under?(authorizing_record.path) }
      end

      true
    end

    def allows?(wanted_level, given_level)
      acceptable_levels =
        case wanted_level
        when ADMIN then [ADMIN]
        when WRITE then [ADMIN, WRITE]
        when READ then [ADMIN, WRITE, READ]
        when CREATE then [ADMIN, WRITE, CREATE]
        else raise "Unknown level: #{query_level}"
        end
      acceptable_levels.include?(given_level)
    end
  end
end
