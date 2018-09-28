class ResourcePath < Dry::Struct
  attribute :elements, Types::Strict::Array.of(Types::Strict::String)

  def initialize(attrs)
    return super(attrs) if attrs.is_a?(Hash)
    self[attrs]
  end

  def self.[](path)
    return path if path.is_a? self
    new(elements: self.sanitized_elements(path || ''))
  end

  def inspect
    "#<ResourcePath #{to_url_path}>"
  end

  def to_key
    (['root'] + elements).join('/')
  end

  def to_url_path
    "/#{elements.join('/')}"
  end

  alias to_s to_url_path

  def depth
    elements.length
  end

  def root?
    elements.empty?
  end

  def parent
    return nil if root?

    @parent ||=
      if elements.size == 1
        ResourcePath.new(elements: [])
      else
        ResourcePath.new(elements: elements[0 .. elements.size - 2])
      end
  end

  def with_ancestors
    list = []
    iter = self
    loop do
      list << iter
      return list if iter.root?
      iter = iter.parent
      raise "List too long, probably infinite recursion; list: #{list[0..9].inspect}" if list.size > 100
    end
  end

  def nests?(other_path)
    return false if other_path.root?
    return true if root?
    return false if other_path.depth <= depth
    other_path.elements[0 .. elements.length - 1] == elements
  end

  def nested_under?(other_path)
    other_path.nests?(self)
  end

  private

  def self.sanitized_elements(path)
    elements = path.split('/').map(&:presence).compact.map(&method(:sanitize_path_element))
    return [] if elements == ['home']
    elements
  end

  def self.sanitize_path_element(s)
    s.parameterize.gsub(/[^a-zA-Z0-9\-]/, '').presence || raise("Invalid path element: #{s.inspect}")
  end
end
