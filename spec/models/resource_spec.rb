require 'mini_helper'

describe Resource do
  before do
    allow_any_instance_of(FileStorage).to receive(:root).and_return(ROOT_PATH)
  end

  describe '.patch_by_path' do
    context 'when new' do
      it 'remembers the body' do
        Resource.patch_by_path(path: 'hello', body: 'Hello')
        expect(Resource.find_by_path('hello').body).to eq 'Hello'
      end

      it 'sets defaults' do
        Resource.patch_by_path(path: 'hello', body: 'Hello')
        resource = Resource.find_by_path('hello')
        expect(resource.id).to be_present
        expect(resource.path).to eq 'hello'
        expect(resource.editor).to be_present
        expect(resource.editor_url).to be_present
      end
    end

    context 'when exists' do
      it 'patches it' do
        Resource.patch_by_path(path: 'hello', body: 'Hello')

        expect {
          Resource.patch_by_path(path: 'hello', body: 'Moin')
        }.to change {
          Resource.find_by_path('hello').body
        }.from('Hello').to('Moin')
      end
    end
  end
end
