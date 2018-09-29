class GetPermissions < ResourceService
  def process
    validate_permission!(ADMIN)

    ResourcePermissions[path].grants.map do |grant|
      grant.attributes.slice(:token, :level).merge(
        path: grant.path.to_url_path
      )
    end
  end
end
