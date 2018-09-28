require 'mini_helper'

describe ShowResource do
  let(:action) { described_class.(path: ResourcePath[path], edit: edit, access_token: access_token )}
  let(:result) { action }
  let(:access_token) { nil }
  let(:edit) { false }
  let(:path) { '/notes' }

  context 'no site-wide permissions' do
    before do
      Storage.reset
    end

    context 'accessing root page' do
      let(:path) { '/' }

      it 'returns blank resource' do
        expect(result.resource_attributes).to be_present
      end
    end
  end

  context 'site-wide permissions exist' do
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
        it 'returns resource' do
          expect(result.resource_attributes).to be_present
          expect(result.resource_attributes[:permissions][:admin]).to eq true
          expect(result.resource_attributes[:permissions][:write]).to eq true
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

        it 'returns details' do
          expect(result.resource_attributes[:title]).to eq 'Hello'
          expect(result.resource_attributes[:body]).to eq '<h1>Hello</h1>'
        end
      end

      context 'readable with token' do
        before do
          resource.permissions.grant!(AccessLevel::READ, 'RdrTkn')
        end

        context 'without token' do
          let(:access_token) { nil }
          it 'raises authorization error' do
            expect { action }.to raise_error(Errors::UnauthorizedError)
          end
        end

        context 'with token' do
          let(:access_token) { 'RdrTkn' }
          it 'returns details' do
            expect(result.resource_attributes[:title]).to eq 'Hello'
          end
        end
      end
    end
  end
end
