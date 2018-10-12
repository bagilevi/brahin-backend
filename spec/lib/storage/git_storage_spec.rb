require 'mini_helper'
require_relative './shared_examples'

describe GitStorage do
  let(:storage) { described_class.new(File.expand_path('tmp/testdata')) }
  it_behaves_like 'storage'
end
