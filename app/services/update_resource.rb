class UpdateResource < ResourceService
  attribute :params, Types::Strict::Hash

  def process
    if resource.exists?
      validate_permission!(WRITE)
      resource.update!(params)
    elsif can?(CREATE)
      create_resource_with_ownership(params)
    else
      raise Errors::NotFoundError.new('Page not found.')
    end
  end

  class Response < Dry::Struct
    attribute :resource_attributes, Types::Any
  end
end
