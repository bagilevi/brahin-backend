require 'rails_helper'

describe PermissionGrant do
  before do
    PermissionGrant.delete_all
    PermissionGrant.create!(
      path: '/',
      token: 'TknAdm',
      level: AccessLevel::ADMIN,
    )
  end

  it 'creates authorization & check' do
    PermissionGrant.create!(
      path: '/foo',
      token: 'Tkn1',
      level: AccessLevel::ADMIN,
    )

    a = PermissionGrant.get_authorization('/foo', 'Tkn1')
    expect(a.can_write?).to be true
  end

  it 'matches all subpaths' do
    PermissionGrant.create!(
      path: '/foo',
      token: 'Tkn1',
      level: AccessLevel::ADMIN,
    )

    a = PermissionGrant.get_authorization('/foo/bar', 'Tkn1')
    expect(a.can_write?).to be true
  end

  context 'when root path is authorized' do
    it 'allows any path' do
      PermissionGrant.create!(
        path: '/',
        token: 'Tkn1',
        level: AccessLevel::ADMIN,
      )
      expect(PermissionGrant.get_authorization('/', 'Tkn1').can_write?).to be true
      expect(PermissionGrant.get_authorization('/foo', 'Tkn1').can_write?).to be true
      expect(PermissionGrant.get_authorization('/foo/bar', 'Tkn1').can_write?).to be true
    end
  end

  context 'when the token is wrong' do
    it 'returns false' do
      PermissionGrant.create!(
        path: '/foo',
        token: 'Tkn1',
        level: AccessLevel::ADMIN,
      )
      expect(PermissionGrant.get_authorization('/foo', 'wrongTkn').can_write?).to be false
    end
  end

  context 'when authorized for admin' do
    before do
      PermissionGrant.create!(
        path: '/foo',
        token: 'Tkn1',
        level: AccessLevel::ADMIN,
      )
    end

    it 'allows read' do
      expect(PermissionGrant.get_authorization('/foo', 'Tkn1').can_read?).to be true
    end

    it 'allows write' do
      expect(PermissionGrant.get_authorization('/foo', 'Tkn1').can_write?).to be true
    end

    it 'allows admin' do
      expect(PermissionGrant.get_authorization('/foo', 'Tkn1').can_admin?).to be true
    end
  end

  context 'when authorized for write' do
    before do
      PermissionGrant.create!(
        path: '/foo',
        token: 'Tkn1',
        level: AccessLevel::WRITE,
      )
    end

    it 'allows read' do
      expect(PermissionGrant.get_authorization('/foo', 'Tkn1').can_read?).to be true
    end

    it 'allows write' do
      expect(PermissionGrant.get_authorization('/foo', 'Tkn1').can_write?).to be true
    end

    it 'does not allow admin' do
      expect(PermissionGrant.get_authorization('/foo', 'Tkn1').can_admin?).to be false
    end
  end

  context 'when authorized for read' do
    before do
      PermissionGrant.create!(
        path: '/foo',
        token: 'Tkn1',
        level: AccessLevel::READ,
      )
    end

    it 'allows read' do
      expect(PermissionGrant.get_authorization('/foo', 'Tkn1').can_read?).to be true
    end

    it 'does not allow write' do
      expect(PermissionGrant.get_authorization('/foo', 'Tkn1').can_write?).to be false
    end

    it 'does not allow admin' do
      expect(PermissionGrant.get_authorization('/foo', 'Tkn1').can_admin?).to be false
    end
  end

  describe 'with a create rule on /users' do
    before do
      PermissionGrant.create!(
        path: '/users',
        token: nil,
        level: AccessLevel::CREATE,
      )
    end

    it 'allows creating under /users' do
      expect(PermissionGrant.get_authorization('/users/joe', 'Tkn2').can_create?).to be true
      expect(PermissionGrant.get_authorization('/users/joe/depth', 'Tkn2').can_create?).to be true
    end

    it 'allows creating /users' do
      expect(PermissionGrant.get_authorization('/users', 'Tkn2').can_create?).to be true
    end

    it 'does not allow creating outside /users' do
      expect(PermissionGrant.get_authorization('/bar', 'Tkn2').can_create?).to be false
    end

    context 'when there is already an authorization rule for that path' do
      before do
        PermissionGrant.create!(
          path: '/users/joe',
          token: 'Tkn1',
          level: AccessLevel::WRITE,
        )
      end

      it 'does not allow creating under that path' do
        expect(PermissionGrant.get_authorization('/users/joe', 'Tkn2').can_create?).to be false
        expect(PermissionGrant.get_authorization('/users/joe/depth', 'Tkn2').can_create?).to be false
      end

      it 'allows creating with the correct token' do
        expect(PermissionGrant.get_authorization('/users/joe', 'Tkn1').can_create?).to be true
        expect(PermissionGrant.get_authorization('/users/joe/depth', 'Tkn1').can_create?).to be true
      end
    end
  end

  context 'when the whole site is available for reading' do
    before do
      PermissionGrant.create!(
        path: '/',
        token: nil,
        level: AccessLevel::READ,
      )
    end

    it 'allows user without token to read' do
      expect(PermissionGrant.get_authorization('/', nil).can_read?).to be true
    end

    it 'allows user with any token to read' do
      expect(PermissionGrant.get_authorization('/', 'Tkn8').can_read?).to be true
    end

    it 'does not allow user without token to write' do
      expect(PermissionGrant.get_authorization('/', nil).can_write?).to be false
    end
  end

  context 'when part of the site is available for reading' do
    before do
      PermissionGrant.create!(
        path: '/foo',
        token: nil,
        level: AccessLevel::READ,
      )
    end

    it 'allows user without token to read anything within that area' do
      expect(PermissionGrant.get_authorization('/foo/bar', nil).can_read?).to be true
    end

    it 'does not allow user without token to write' do
      expect(PermissionGrant.get_authorization('/foo/bar', nil).can_write?).to be false
    end

    it 'does not allow user to read outside that area' do
      expect(PermissionGrant.get_authorization('/', nil).can_read?).to be false
    end
  end

  describe 'admin' do
    it 'allows admin to do anything' do
      expect(PermissionGrant.get_authorization('/foo/bar', 'TknAdm').can_read?).to be true
      expect(PermissionGrant.get_authorization('/foo/bar', 'TknAdm').can_write?).to be true
      expect(PermissionGrant.get_authorization('/foo/bar', 'TknAdm').can_admin?).to be true
    end

    context 'when someone else owns a sub-path' do
      before do
        PermissionGrant.create!(
          path: '/foo/bar',
          token: 'Tkn2',
          level: AccessLevel::ADMIN,
        )
      end

      it 'still allows admin to do anything' do
        expect(PermissionGrant.get_authorization('/foo/bar', 'TknAdm').can_read?).to be true
        expect(PermissionGrant.get_authorization('/foo/bar', 'TknAdm').can_write?).to be true
        expect(PermissionGrant.get_authorization('/foo/bar', 'TknAdm').can_admin?).to be true
      end
    end
  end

  describe 'when someone else owns a sub-path' do
    before do
      PermissionGrant.create!(
        path: '/foo',
        token: nil,
        level: AccessLevel::READ,
      )
      PermissionGrant.create!(
        path: '/foo/bar',
        token: 'Tkn2',
        level: AccessLevel::ADMIN,
      )
    end

    it 'ignores rule above that path' do
      expect(PermissionGrant.get_authorization('/foo/bar', nil).can_read?).to be false
    end
  end

  describe 'find_highest_path' do
    context 'token is defined on the same path' do
      before do
        PermissionGrant.create!(
          path: '/foo/bar',
          token: 'RdrTkn',
          level: AccessLevel::READ,
        )
      end

      it 'returns the path which has the token' do
        result = PermissionGrant.find_highest_path('/foo/bar', 'RdrTkn')
        expect(result.to_s).to eq '/foo/bar'
      end
    end

    context 'token is defined on a higher path' do
      before do
        PermissionGrant.create!(
          path: '/foo',
          token: 'RdrTkn',
          level: AccessLevel::READ,
        )
      end

      it 'returns the path which has the token' do
        result = PermissionGrant.find_highest_path('/foo/bar', 'RdrTkn')
        expect(result.to_s).to eq '/foo'
      end
    end

    context 'token is defined on a deeper path' do
      before do
        PermissionGrant.create!(
          path: '/foo/bar/zoo',
          token: 'RdrTkn',
          level: AccessLevel::READ,
        )
      end

      it 'returns nothing' do
        result = PermissionGrant.find_highest_path('/foo/bar', 'RdrTkn')
        expect(result).to be_nil
      end
    end
  end
end
