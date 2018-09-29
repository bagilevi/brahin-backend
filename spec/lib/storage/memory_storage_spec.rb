require 'mini_helper'
require_relative './shared_examples'

describe MemoryStorage do
  let(:storage) { described_class.new }
  it_behaves_like 'storage'
end
