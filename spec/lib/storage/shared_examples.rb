shared_examples 'storage' do
  let(:foo_path) { ResourcePath['/foo'] }
  let(:bar_path) { ResourcePath['/bar'] }

  before do
    storage.reset
  end

  describe '#get' do
    it 'returns nil if missing' do
      expect(storage.get(foo_path, 'body.html')).to be_nil
    end

    it 'returns value that has been put' do
      storage.put(foo_path, 'body.html', 'foo')
      expect(storage.get(foo_path, 'body.html')).to eq 'foo'
    end
  end

  describe '#put' do
    it 'overwrites previously set value' do
      storage.put(foo_path, 'body.html', 'foo')
      expect {
        storage.put(foo_path, 'body.html', 'bar')
      }.to change {
        storage.get(foo_path, 'body.html')
      }.from('foo').to('bar')
    end
  end

  describe '#del' do
    it 'deletes value' do
      storage.put(foo_path, 'body.html', 'foo')
      expect {
        storage.del(foo_path, 'body.html')
      }.to change {
        storage.get(foo_path, 'body.html')
      }.from('foo').to(nil)
    end
  end

  describe "#reset" do
    before do
      storage.put(foo_path, 'body.html', 'foo')
      storage.put(foo_path, 'meta.yml', 'foo')
      storage.put(bar_path, 'body.html', 'bar')
      storage.put(bar_path, 'meta.yml', 'bar')
    end

    it 'deletes everything' do
      storage.reset
      expect(storage.get(foo_path, 'body.html')).to be_nil
      expect(storage.get(foo_path, 'meta.yml')).to be_nil
      expect(storage.get(bar_path, 'body.html')).to be_nil
      expect(storage.get(bar_path, 'meta.yml')).to be_nil
    end
  end

  describe '#delete_all_parts' do
    before do
      storage.put(foo_path, 'body.html', 'foo')
      storage.put(foo_path, 'meta.yml', 'foo')
      storage.put(bar_path, 'body.html', 'bar')
      storage.put(bar_path, 'meta.yml', 'bar')
    end

    it 'deletes all parts of a type' do
      storage.delete_all_parts('meta.yml')
      expect(storage.get(foo_path, 'body.html')).to be_present
      expect(storage.get(foo_path, 'meta.yml')).to be_nil
      expect(storage.get(bar_path, 'body.html')).to be_present
      expect(storage.get(bar_path, 'meta.yml')).to be_nil
    end
  end
end
