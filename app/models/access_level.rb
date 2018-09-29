module AccessLevel
  extend self

  NONE = 0
  CREATE = 1
  READ = 2
  WRITE = 3
  ADMIN = 4

  def level_from_string(s)
    case s.strip.downcase
    when 'create' then CREATE
    when 'read' then READ
    when 'write' then WRITE
    when 'admin' then ADMIN
    end
  end
end
