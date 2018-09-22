class PathAuthorization < ApplicationRecord
  include AccessLevel

  def self.get(input_path, input_token)
    records = where(path: match_paths(input_path)).all.to_a

    if records.none? { |r| r.level == ADMIN }
      # Nobody owns this site => first visitor takes ownership
      record = create!(path: '/', level: ADMIN, token: input_token)
      records = [record]
    end

    return Authorization.new(records, input_path, input_token)
  end

  def self.find_highest_path(input_path, input_token)
    where(path: match_paths(input_path), token: input_token).pluck(:path).min_by(&:length)
  end

  def self.update_all_for_path(path, entries)
    transaction do
      where(path: path).delete_all
      if entries.is_a?(Hash)
        entries = entries.map { |k, v| v }
      end
      entries.each do |attrs|
        create!(
          path: path,
          token: attrs[:token].presence,
          level: attrs[:level]&.to_i,
        )
      end
    end
  end

  def self.match_paths(path)
    elements = path == '/' ? [""] : path.split('/')
    (0 .. elements.size - 1).map { |i| i == 0 ? '/' : elements[0 .. i].join('/') }
  end

  def path_nests?(other_path)
    return false if other_path == '/'
    return true if path == '/'
    other_path.starts_with?("#{path}/")
  end

  def path_nested_under?(other_path)
    return false if path == '/'
    return true if other_path == '/'
    path.starts_with?("#{other_path}/")
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
      @records = records
      container_path = @records.select { |r| r.level == ADMIN }.map(&:path).max_by(&:length)
      @records.reject! { |r| r.path_nests?(container_path) }

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
        return false if other_records.any? { |r| r.path_nested_under?(authorizing_record.path) }
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
