class UpdatePermissions < ResourceService
  attribute :grants, Types::Strict::Array

  def process
    validate_permission!(ADMIN)

    PermissionGrant.update_all_for_path(
      path,
      grants
    )
  end
end
