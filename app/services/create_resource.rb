class CreateResource < ResourceService
  attribute :params, Types::Strict::Hash

  def process
    validate_permission!(CREATE)

    if resource.exists?
      raise Errors::AlreadyExistsError.new('Page already exists.')
    else
      create_resource_with_ownership(params)
    end
  end

  class Response < Dry::Struct
    attribute :resource_attributes, Types::Any
  end
end
