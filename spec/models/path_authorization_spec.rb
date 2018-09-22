require 'rails_helper'

describe PathAuthorization do
  before do
    PathAuthorization.delete_all
    PathAuthorization.create!(
      path: '/',
      token: 'TknAdm',
      level: AccessLevel::ADMIN,
    )
  end

  it 'creates authorization & check' do
    expect {
      PathAuthorization.create!(
        path: '/foo',
        token: 'Tkn1',
        level: AccessLevel::ADMIN,
      )
    }.to change { PathAuthorization.count }.by(1)

    a = PathAuthorization.get('/foo', 'Tkn1')
    expect(a.can_write?).to be true
  end

  it 'matches all subpaths' do
    PathAuthorization.create!(
      path: '/foo',
      token: 'Tkn1',
      level: AccessLevel::ADMIN,
    )

    a = PathAuthorization.get('/foo/bar', 'Tkn1')
    expect(a.can_write?).to be true
  end

  context 'when root path is authorized' do
    it 'allows any path' do
      PathAuthorization.create!(
        path: '/',
        token: 'Tkn1',
        level: AccessLevel::ADMIN,
      )
      expect(PathAuthorization.get('/', 'Tkn1').can_write?).to be true
      expect(PathAuthorization.get('/foo', 'Tkn1').can_write?).to be true
      expect(PathAuthorization.get('/foo/bar', 'Tkn1').can_write?).to be true
    end
  end

  context 'when the token is wrong' do
    it 'returns false' do
      PathAuthorization.create!(
        path: '/foo',
        token: 'Tkn1',
        level: AccessLevel::ADMIN,
      )
      expect(PathAuthorization.get('/foo', 'wrongTkn').can_write?).to be false
    end
  end

  context 'when authorized for admin' do
    before do
      PathAuthorization.create!(
        path: '/foo',
        token: 'Tkn1',
        level: AccessLevel::ADMIN,
      )
    end

    it 'allows read' do
      expect(PathAuthorization.get('/foo', 'Tkn1').can_read?).to be true
    end

    it 'allows write' do
      expect(PathAuthorization.get('/foo', 'Tkn1').can_write?).to be true
    end

    it 'allows admin' do
      expect(PathAuthorization.get('/foo', 'Tkn1').can_admin?).to be true
    end
  end

  context 'when authorized for write' do
    before do
      PathAuthorization.create!(
        path: '/foo',
        token: 'Tkn1',
        level: AccessLevel::WRITE,
      )
    end

    it 'allows read' do
      expect(PathAuthorization.get('/foo', 'Tkn1').can_read?).to be true
    end

    it 'allows write' do
      expect(PathAuthorization.get('/foo', 'Tkn1').can_write?).to be true
    end

    it 'does not allow admin' do
      expect(PathAuthorization.get('/foo', 'Tkn1').can_admin?).to be false
    end
  end

  context 'when authorized for read' do
    before do
      PathAuthorization.create!(
        path: '/foo',
        token: 'Tkn1',
        level: AccessLevel::READ,
      )
    end

    it 'allows read' do
      expect(PathAuthorization.get('/foo', 'Tkn1').can_read?).to be true
    end

    it 'does not allow write' do
      expect(PathAuthorization.get('/foo', 'Tkn1').can_write?).to be false
    end

    it 'does not allow admin' do
      expect(PathAuthorization.get('/foo', 'Tkn1').can_admin?).to be false
    end
  end

  describe 'with a create rule on /users' do
    before do
      PathAuthorization.create!(
        path: '/users',
        token: nil,
        level: AccessLevel::CREATE,
      )
    end

    it 'allows creating under /users' do
      expect(PathAuthorization.get('/users/joe', 'Tkn2').can_create?).to be true
      expect(PathAuthorization.get('/users/joe/depth', 'Tkn2').can_create?).to be true
    end

    it 'allows creating /users' do
      expect(PathAuthorization.get('/users', 'Tkn2').can_create?).to be true
    end

    it 'does not allow creating outside /users' do
      expect(PathAuthorization.get('/bar', 'Tkn2').can_create?).to be false
    end

    context 'when there is already an authorization rule for that path' do
      before do
        PathAuthorization.create!(
          path: '/users/joe',
          token: 'Tkn1',
          level: AccessLevel::WRITE,
        )
      end

      it 'does not allow creating under that path' do
        expect(PathAuthorization.get('/users/joe', 'Tkn2').can_create?).to be false
        expect(PathAuthorization.get('/users/joe/depth', 'Tkn2').can_create?).to be false
      end

      it 'allows creating with the correct token' do
        expect(PathAuthorization.get('/users/joe', 'Tkn1').can_create?).to be true
        expect(PathAuthorization.get('/users/joe/depth', 'Tkn1').can_create?).to be true
      end
    end
  end

  context 'when the whole site is available for reading' do
    before do
      PathAuthorization.create!(
        path: '/',
        token: nil,
        level: AccessLevel::READ,
      )
    end

    it 'allows user without token to read' do
      expect(PathAuthorization.get('/', nil).can_read?).to be true
    end

    it 'allows user with any token to read' do
      expect(PathAuthorization.get('/', 'Tkn8').can_read?).to be true
    end

    it 'does not allow user without token to write' do
      expect(PathAuthorization.get('/', nil).can_write?).to be false
    end
  end

  context 'when part of the site is available for reading' do
    before do
      PathAuthorization.create!(
        path: '/foo',
        token: nil,
        level: AccessLevel::READ,
      )
    end

    it 'allows user without token to read anything within that area' do
      expect(PathAuthorization.get('/foo/bar', nil).can_read?).to be true
    end

    it 'does not allow user without token to write' do
      expect(PathAuthorization.get('/foo/bar', nil).can_write?).to be false
    end

    it 'does not allow user to read outside that area' do
      expect(PathAuthorization.get('/', nil).can_read?).to be false
    end
  end

  describe 'admin' do
    it 'allows admin to do anything' do
      expect(PathAuthorization.get('/foo/bar', 'TknAdm').can_read?).to be true
      expect(PathAuthorization.get('/foo/bar', 'TknAdm').can_write?).to be true
      expect(PathAuthorization.get('/foo/bar', 'TknAdm').can_admin?).to be true
    end
  end

  describe 'when someone is owns a sub-path' do
    before do
      PathAuthorization.create!(
        path: '/foo',
        token: nil,
        level: AccessLevel::READ,
      )
      PathAuthorization.create!(
        path: '/foo/bar',
        token: 'Tkn2',
        level: AccessLevel::ADMIN,
      )
    end

    it 'ignores rule above that path' do
      expect(PathAuthorization.get('/foo/bar', nil).can_read?).to be false
    end
  end
end
