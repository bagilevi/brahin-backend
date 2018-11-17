class CreateResource < ResourceService
  attribute :params, Types::Strict::Hash

  def process
    validate_permission!(CREATE)

    if resource.exists?
      raise Errors::AlreadyExistsError.new('Page already exists.')
    else
      create_resource_with_ownership(params)
      resource_response
    end
  end
end
