require 'mini_helper'

describe CreateResource do
  let(:action) { described_class.(path: ResourcePath[path], params: params, access_token: access_token )}
  let(:result) { action }
  let(:access_token) { 'Tkn1' }
  let(:params) { { title: 'Created', body: '<h1>Created</h1>'} }
  let(:path) { '/notes' }


  context 'no site-wide permissions' do
    before do
      Storage.reset
    end

    context 'with root page' do
      let(:path) { '/' }

      it 'creates resource' do
        expect { action }
          .to change { Resource[path].title }
          .from(nil).to('Created')
      end
    end
  end

  context 'site-wide permissions exist' do
    before do
      Storage.reset
      PermissionGrant.create!(path: '/', level: AccessLevel::ADMIN, token: 'OwnrTkn')
    end

    context 'resource does not exist, not authorized to create' do
      it 'raises authorization error' do
        expect { action }.to raise_error(Errors::UnauthorizedError)
      end

      context 'with a create permission on the container' do
        before do
          Resource['/'].permissions.grant_to_public!(AccessLevel::CREATE)
        end

        it 'creates resource' do
          expect { action }
            .to change { Resource[path].title }
            .from(nil).to('Created')
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
          expect { action }.to raise_error(Errors::AlreadyExistsError)
        end
      end
    end
  end
end
