class ResourceBody < Dry::Struct
  include Dry::Struct::Setters
  include Storage

  PART = 'body.html'.freeze

  attribute :path, ResourcePath
  attribute :body, Types::Coercible::String.optional

  def self.[](path)
    path = ResourcePath[path]
    payload = storage.get(path, PART)
    new(path: path, body: payload)
  end

  def save
    storage.put(path, PART, body)
  end

  def exists?
    !body.nil?
  end
end
