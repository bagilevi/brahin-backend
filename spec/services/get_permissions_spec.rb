require 'mini_helper'

describe GetPermissions do
  let(:action) { described_class.(path: ResourcePath[path], access_token: access_token )}
  let(:result) { action }
  let(:access_token) { 'Tkn1' }
  let(:path) { '/notes' }


  context 'no site-wide permissions' do
    before do
      Storage.reset
    end

    context 'with root page' do
      let(:path) { '/' }

      it 'creates first permission entry' do
        expect { action }
          .to change { Access['/'].authorizations.count }.by(1)

        expect(result.size).to eq 1
        expect(result[0][:path]).to eq '/'
        expect(result[0][:level]).to eq 4
        expect(result[0][:token]).to eq 'Tkn1'
      end
    end
  end

  context 'site-wide permissions exist' do
    before do
      Storage.reset
      PathAuthorization.create!(path: '/', level: AccessLevel::ADMIN, token: 'OwnrTkn')
    end

    context 'queried by site owner' do
      let(:path) { '/' }
      let(:access_token) { 'OwnrTkn' }

      it 'returns permissions' do
        expect(result.size).to eq 1
        expect(result[0][:path]).to eq '/'
        expect(result[0][:level]).to eq AccessLevel::ADMIN
        expect(result[0][:token]).to eq 'OwnrTkn'
      end
    end
  end
end
