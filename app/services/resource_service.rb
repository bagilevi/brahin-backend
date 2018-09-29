class ResourceService < Dry::Struct
  extend Memoist
  include AccessLevel

  attribute :path, ResourcePath
  attribute :access_tokens, Types::Array.optional.default { [] }
  attribute :access_token, Types::Strict::String.optional.default(nil)

  def self.call(attrs)
    catch :halt do
      new(attrs).process
    end
  end

  def resource
    Resource[path]
  end
  memoize :resource

  def validate_permission!(action_level)
    return if can?(action_level)
    message =
      case action_level
      when READ then 'You are not authorized to see this page.'
      when WRITE then 'You are not authorized to edit this page.'
      when CREATE then 'You are not authorized to create a page here.'
      else 'You are not authorized to do this.'
      end
    raise Errors::UnauthorizedError.new(message)
  end

  def can?(action_level)
    @authorization ||= PermissionGrant.get_authorization(path, all_access_tokens)
    @authorization.can?(action_level)
  end

  def create_resource_with_ownership(params = {})
    resource.create!(params)

    unless can?(ADMIN)
      PermissionGrant.create!(
        path: path,
        token: access_token,
        level: AccessLevel::ADMIN,
      )
    end
  end

  private

  def all_access_tokens
    [access_token].compact + (access_tokens || [])
  end
end
