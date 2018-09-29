# Logic determining what the user can and cannot do.
class Authorization
  include AccessLevel

  def initialize(grants, path, token)
    @grants = grants
    container_path = @grants.select { |r| r.level == ADMIN }.map(&:path).max_by(&:depth)
    @grants.reject! { |r| r.path.nests?(container_path) }

    @path = path
    @token = token
  end

  def can?(wanted_level)
    matching_records = @grants.select { |r| r.token.nil? || r.token == @token }
    other_records = @grants - matching_records

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

  def can_create?; can? CREATE end
  def can_read?;   can? READ   end
  def can_write?;  can? WRITE  end
  def can_admin?;  can? ADMIN  end
end
