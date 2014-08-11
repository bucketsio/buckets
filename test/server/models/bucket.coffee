User = require('../../../server/models/user')
Bucket = require('../../../server/models/bucket')
db = require('../../../server/lib/database')

{assert} = require('chai')

describe 'Bucket', ->
  before (done) ->
    db.connection.db.dropDatabase done
  afterEach (done) ->
    db.connection.db.dropDatabase done

  describe '#getMembers', ->
    it 'returns members', (done) ->
      Bucket.create { name: 'Images', slug: 'images' }, (e, bucket) ->
        throw e if e
        User.create { name: 'Bucketer', email: 'hello@buckets.io', password: 'S3cr3ts' }, (e, u) ->

          u.upsertRole 'contributor', bucket, (e, user) ->
            throw e if e

            bucket.getMembers (e, users) ->
              throw e if e
              assert.isArray(users)
              assert.lengthOf(users, 1)
              assert.equal(users[0].id, u.id)

              done()
