require 'mini_helper'

describe UpdatePermissions do
  let(:action) { described_class.(path: ResourcePath[path], access_token: access_token, grants: grants )}
  let(:result) { action }
  let(:access_token) { 'Tkn1' }
  let(:path) { '/notes' }

  context 'site-wide permissions exist' do
    before do
      Storage.reset
      PermissionGrant.create!(path: '/', level: AccessLevel::ADMIN, token: 'OwnrTkn')
    end

    context 'updated by site owner' do
      let(:path) { '/' }
      let(:access_token) { 'OwnrTkn' }
      let(:grants) {
        [
          {
            level: AccessLevel::ADMIN,
            token: 'OwnrTkn'
          },
          {
            level: AccessLevel::READ,
            token: 'RdrTkn'
          }
        ]
      }

      it 'updates permissions' do
        action
        expect(PermissionGrant.get_authorization('/', 'RdrTkn').can?(AccessLevel::READ)).to be true
      end
    end
  end
end
