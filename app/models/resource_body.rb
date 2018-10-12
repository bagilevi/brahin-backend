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
    storage.put(path, PART, normalize_html(body))
  end

  def exists?
    !body.nil?
  end

  def normalize_html(html)
    doc = Nokogiri::XML("<wrapper>#{html}</wrapper>", &:noblanks)
    lines = doc.to_xhtml(indent: 0).split("\n")
    lines[1..-2].join("\n") << "\n"
  rescue => e
    Rails.logger.error("Could not normalize HTML, returning original - Cause: #{e.class.name}: #{e.message}")
    html
  end
end
