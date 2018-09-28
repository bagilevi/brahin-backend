require 'mini_helper'

describe UpdateResource do
  let(:action) { described_class.(path: ResourcePath[path], params: params, access_token: access_token )}
  let(:result) { action }
  let(:access_token) { 'Tkn1' }
  let(:params) { { title: 'Updated', body: '<h1>Updated</h1>'} }
  let(:path) { '/notes' }

  before do
    Storage.reset
    PathAuthorization.create!(path: '/', level: AccessLevel::ADMIN, token: 'OwnrTkn')
  end

  context 'resource does not exist' do
    it 'raises not found' do
      expect { action }.to raise_error(Errors::NotFoundError)
    end

    context 'with a create permission on the container' do
      before do
        Resource['/'].permissions.grant_to_public!(AccessLevel::CREATE)
      end

      it 'creates resource' do
        expect { action }
          .to change { Resource[path].title }
          .from(nil).to('Updated')
      end

      it 'makes the creator the owner' do
        action
        expect(PathAuthorization.get('/notes', 'Tkn1').can?(AccessLevel::ADMIN)).to be true
      end
    end
  end

  context 'resource exists' do
    let!(:resource) { Resource[path].create!(title: 'Hello', body: '<h1>Hello</h1>') }

    context 'no permissions' do
      it 'raises authorization error' do
        expect { action }.to raise_error(Errors::UnauthorizedError)
      end
    end

    context 'readable to anyone' do
      before do
        resource.make_publicly_readable!
      end

      it 'raises authorization error' do
        expect { action }.to raise_error(Errors::UnauthorizedError)
      end
    end

    context 'writable to anyone' do
      before do
        resource.permissions.grant_to_public!(AccessLevel::WRITE)
      end

      it 'updates resource' do
        expect { action }
          .to change { Resource[path].title }
          .from('Hello').to('Updated')
      end
    end

    context 'readable/writable with token' do
      before do
        resource.permissions.grant!(AccessLevel::READ, 'RdrTkn')
        resource.permissions.grant!(AccessLevel::WRITE, 'WrtrTkn')
      end

      context 'without token' do
        let(:access_token) { nil }
        it 'raises authorization error' do
          expect { action }.to raise_error(Errors::UnauthorizedError)
        end
      end

      context 'with reading token' do
        let(:access_token) { 'RdrTkn' }
        it 'raises authorization error' do
          expect { action }.to raise_error(Errors::UnauthorizedError)
        end
      end

      context 'with writing token' do
        let(:access_token) { 'WrtrTkn' }
        it 'updates resource' do
          expect { action }
            .to change { Resource[path].title }
            .from('Hello').to('Updated')
        end
      end
    end
  end
end
