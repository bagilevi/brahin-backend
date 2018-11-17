class ShowResource < ResourceService
  attribute :edit, Types::Strict::Bool

  def process
    if resource.exists?
      edit ? validate_permission!(WRITE) : validate_permission!(READ)
    elsif can?(CREATE)
      @creating = true
      create_resource_with_ownership
      @authorization = nil
    else
      raise Errors::NotFoundError.new('Page not found.')
    end
    resource_response
  end

  class Response < Dry::Struct
    attribute :resource_attributes, Types::Any
  end
end
