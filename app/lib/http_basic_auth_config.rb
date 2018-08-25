class HttpBasicAuthConfig
  def initialize(config_value)
    @entries = config_value.split(';').map { |element| element.split(':')}
    # E.g.
    #
    #      HTTP_BASIC_AUTHENTICATION="read:*:*;write:mary:Pass1"
    #
    # will have the effect of:
    #
    #      @entries =
    #        [
    #          ['read', '*', '*'],
    #          ['write', 'mary', 'Pass1'],
    #        ]
  end

  def has_wildcard?(perm)
    @entries.any? { |iperm, iuser, ipass| iperm == perm && iuser == '*' }
  end

  def match?(perm, user, pass)
    @entries.any? { |iperm, iuser, ipass| iperm == perm && iuser == user && ipass == pass}
  end
end
