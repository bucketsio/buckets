User = require('../../../server/models/user')
Bucket = require('../../../server/models/bucket')
reset = require('../../reset')

{assert} = require('chai')

describe 'Bucket', ->
  before reset.db
  afterEach reset.db

  describe '#getMembers', ->
    bucket = null
    user = null

    before (done) ->
      Bucket.create { name: 'Images', slug: 'images' }, (e, bkt) ->
        throw e if e
        bucket = bkt
        User.create { name: 'Bucketer', email: 'hello@buckets.io', password: 'S3cr3ts' }, (e, u) ->
          user = u
          u.upsertRole 'contributor', bucket, (e) ->
            throw e if e
            done()

    it 'returns members', (done) ->
      bucket.getMembers (e, users) ->
        throw e if e
        assert.isArray(users)
        assert.lengthOf(users, 1)
        assert.equal(users[0].id, user.id)

        done()
