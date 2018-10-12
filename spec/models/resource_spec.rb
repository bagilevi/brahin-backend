require 'mini_helper'

describe Resource do
  before do
    Storage.reset
  end

  let(:body1) { "<h1>Hello</h1>\n" }
  let(:body2) { "<h1>Moin</h1>\n" }

  describe '.create!' do
    it 'sets defaults' do
      Resource['/hello'].create!(body: body1)
      resource = Resource['/hello']
      expect(resource.path.to_s).to eq '/hello'
      expect(resource.editor).to be_present
      expect(resource.editor_url).to be_present
    end
  end

  describe '.update!' do
    context 'when new' do
      it 'remembers the body' do
        Resource.patch_by_path(path: 'hello', body: body1)
        expect(Resource.find_by_path('hello').body).to eq body1
      end
    end

    context 'when exists' do
      it 'patches it' do
        Resource.patch_by_path(path: 'hello', body: body1)

        expect {
          Resource.patch_by_path(path: 'hello', body: body2)
        }.to change {
          Resource.find_by_path('hello').body
        }.from(body1).to(body2)
      end
    end
  end

  describe '#exists?' do
    context 'if non-existent' do
      it 'returns false' do
        expect(Resource['/x'].exists?).to be false
      end
    end

    context 'when it was created' do
      it 'returns true' do
        resource = Resource['/x']
        resource.body = ""
        resource.save
        expect(Resource['/x'].exists?).to be true
      end
    end
  end
end
