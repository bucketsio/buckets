User = require('../../../server/models/user')
Bucket = require('../../../server/models/bucket')
db = require('../../../server/lib/database')
{assert} = require('chai')

describe 'User', ->
  bucket = null
  user = null

  beforeEach (done) ->
    Bucket.create { name: 'Images', slug: 'images' }, (e, b) ->
      throw e if e
      bucket = b
      User.create { name: 'Bucketer', email: 'hello@buckets.io', password: 'S3cr3ts' }, (e, u) ->
        throw e if e
        user = u

        done()

  afterEach (done) ->
    db.connection.db.dropDatabase(done)

  describe 'password virtual', ->
    describe 'updating password', ->
      it 'updates password', (done) ->
        p = 'abc123'
        user.password = p
        user.save ->
          assert.isTrue(user.authenticate(p))
          assert.isNull(user.password)
          done()

    describe 'when password is missing', ->
      it 'returns an error', (done) ->
        User.create { name: 'Bucketer', email: 'hello@buckets.io' }, (e, u) ->
          assert.equal(e.errors.password.message, 'Password is required')
          done()

    describe 'when password is invalid', ->
      it 'returns an error', (done) ->
        User.create { name: 'Bucketer', email: 'hello@buckets.io', password: 'abc12' }, (e, u) ->
          assert.equal(e.errors.password.message, 'Your password must be between 6–20 characters, start with a letter, and include a number')
          done()

  describe '#addRole', ->
    describe 'when a role is passed', ->
      it 'adds the global role', (done) ->
        user.addRole 'administrator', ->
          assert.lengthOf(user.roles, 1)
          user.addRole 'administrator', ->
            assert.lengthOf(user.roles, 1)
            done()

    describe 'when a role and a resource are passed', ->
      it 'adds the scoped role', (done) ->
        user.addRole 'editor', bucket, ->
          assert.lengthOf(user.roles, 1)
          user.addRole 'ninja', bucket, ->
            assert.lengthOf(user.roles, 2)
            user.addRole 'editor', bucket, ->
              assert.lengthOf(user.roles, 2)
              done()

  describe '#upsertRole', ->
    describe 'when user does not have a role for a resource', ->
      it 'adds a role for the given resource', (done) ->
        user.upsertRole 'editor', bucket, ->
          assert.lengthOf(user.roles, 1)
          assert.equal(user.roles[0].name, 'editor')
          done()

    describe 'when user has a role for a resource', ->
      beforeEach (done) ->
        user.upsertRole('editor', bucket, done)

      it 'updates the role for a given resource', (done) ->
        user.upsertRole 'contributor', bucket, (e, u) ->
          assert.lengthOf(user.roles, 1)
          assert.equal(user.roles[0].name, 'contributor')
          done()

  describe '#removeRole', ->
    beforeEach (done) ->
      user.upsertRole('editor', bucket, done)

    it 'removes the role for a resource', (done) ->
      user.removeRole bucket, (e, u) ->
        assert.lengthOf(user.roles, 0)
        done()

  describe '#hasRole', ->
    describe 'when a resource is passed', ->
      beforeEach (done) ->
        user.upsertRole('editor', bucket, done)

      describe 'when user has the role for the resource', ->
        it 'returns true', ->
          assert.isTrue(user.hasRole('editor', bucket))

      describe 'when user does not have the role for the resource', ->
        it 'returns false', ->
          assert.isFalse(user.hasRole('contributor', bucket))
          assert.isFalse(user.hasRole('administrator'))

    describe 'when user is administrator', ->
      beforeEach (done) ->
        user.addRole('administrator', done)

      it 'returns true', ->
        assert.isTrue(user.hasRole('administrator'))
        assert.isTrue(user.hasRole('editor', bucket))

  describe '#getRoles', ->
    beforeEach (done) ->
      user.upsertRole('editor', bucket, done)

    describe 'when a resource is passed', ->
      it 'returns role for the resource', ->
        roles = user.getRoles(bucket)

        assert.isArray(roles)
        assert.lengthOf(roles, 1)

    describe 'when a resource type is passed', ->
      it 'returns role for the resource type', ->
        roles = user.getRoles('Bucket')

        assert.isArray(roles)
        assert.lengthOf(roles, 1)

  describe '#getResources', ->
    describe 'when user is administrator', ->
      beforeEach (done) ->
        user.addRole('administrator', done)

      it 'returns all buckets', (done) ->
        user.getBuckets (e, buckets) ->
          assert.isArray(buckets)
          assert.lengthOf(buckets, 1)
          assert.equal(buckets[0].id, bucket.id)
          done()

    describe 'when user is not administrator', ->
      beforeEach (done) ->
        user.upsertRole('editor', bucket, done)

      it 'returns buckets where user is editor or contributor', (done) ->
        user.getBuckets (e, buckets) ->
          assert.isArray(buckets)
          assert.lengthOf(buckets, 1)
          assert.equal(buckets[0].id, bucket.id)
          done()

