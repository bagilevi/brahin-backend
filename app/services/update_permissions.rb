class UpdatePermissions < ResourceService
  attribute :entries, Types::Strict::Array

  def process
    validate_permission!(ADMIN)

    PathAuthorization.update_all_for_path(
      path,
      entries
    )
  end
end
