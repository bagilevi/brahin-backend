class GetPermissions < ResourceService
  def process
    validate_permission!(ADMIN)

    Access[path].authorizations.map do |entry|
      entry.attributes.slice(:token, :level).merge(
        path: entry.path.to_url_path
      )
    end
  end
end
