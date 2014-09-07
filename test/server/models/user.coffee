User = require '../../../server/models/user'
Bucket = require '../../../server/models/bucket'
reset = require '../../reset'

{assert} = require 'chai'

describe 'Model#User', ->
  bucket = null
  user = null

  before reset.db

  beforeEach (done) ->
    Bucket.create
      name: 'Images'
      slug: 'images'
    , (e, b) ->
      throw e if e
      bucket = b
      User.create
        name: 'Bucketer'
        email: 'hello@buckets.io'
        password: 'S3cr3ts'
      , (e, u) ->
        throw e if e
        user = u
        done()

  afterEach reset.db

  describe 'Validation', ->
    it 'validates a well-formatted email', (done) ->
      user.email = 'hello@buckets.io'
      user.save (e, u) ->
        assert.isNull(e)
        done()

    it 'returns an error with invalid email', (done) ->
      user.email = 'invalid'
      user.save (e, u) ->
        assert.equal(e.errors.email.message, 'Not a valid email adress')
        done()

    it 'returns an error for a missing password', (done) ->
      User.create { name: 'Bucketer', email: 'hello@buckets.io' }, (e, u) ->
        assert.equal(e.errors.password.message, 'A password is required.')
        done()

    it 'returns an error when password is invalid', (done) ->
      User.create { name: 'Bucketer', email: 'hello@buckets.io', password: 'abc12' }, (e, u) ->
        assert.equal(e.errors.password.message, 'Your password must be between 6–20 characters and include a number.')
        done()

    it 'returns an error if the email is not unique', (done) ->
      User.create
        name: 'Other Bucketer'
        email: 'hello@buckets.io'
        password: 'xyz123'
      , (e, u) ->
        assert.match e, /ValidationError/
        done()

  describe 'Update', ->
    it 'updates password', (done) ->
      p = '1337abc123'
      user.password = p
      user.save ->
        assert.isTrue(user.authenticate(p))
        assert.isFalse(user.authenticate('bad password'))
        assert.isNull(user.password)
        done()

  describe '#upsertRole', ->
    it 'Adds a global role', (done) ->
      user.upsertRole 'administrator', ->
        assert.lengthOf(user.roles, 1)
        user.upsertRole 'administrator', ->
          assert.lengthOf(user.roles, 1)
          done()

    it 'Adds a role for a given resource', (done) ->
      user.upsertRole 'editor', bucket, ->
        assert.lengthOf(user.roles, 1)
        assert.equal(user.roles[0].name, 'editor')
        done()

    describe 'Updates existing roles', ->
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

    it 'checks for a role', ->
      user.upsertRole 'editor', bucket, ->
        assert.isTrue(user.hasRole('editor', bucket))
        assert.isFalse(user.hasRole('contributor', bucket))
        assert.isFalse(user.hasRole('administrator'))

    it 'always returns true for admins', ->
      user.upsertRole 'administrator', ->
        assert.isTrue(user.hasRole('administrator'))
        assert.isTrue(user.hasRole('editor', bucket))
        assert.isTrue(user.hasRole('contributor', bucket))

  describe '#getRoles', ->
    beforeEach (done) ->
      user.upsertRole('editor', bucket, done)

    it 'returns role for a resource (object)', ->
      roles = user.getRoles(bucket)

      assert.isArray(roles)
      assert.lengthOf(roles, 1)

    it 'returns role for a resource type (string)', ->
      roles = user.getRoles('Bucket')

      assert.isArray(roles)
      assert.lengthOf(roles, 1)

  describe '#getResources', ->
    describe 'when user is administrator', ->
      beforeEach (done) ->
        user.upsertRole('administrator', done)

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
