User = require('../../../server/models/user')
Bucket = require('../../../server/models/bucket')
db = require('../../../server/lib/database')
{assert} = require('chai')

describe 'Bucket', ->
  afterEach (done) ->
    for _, c of db.connection.collections
      c.remove(->)
      done()

  describe '#getMembers', ->
    it 'returns members', (done) ->
      Bucket.create { name: 'Images', slug: 'images', singular: 'image' }, (e, bucket) ->
        throw e if e

        u = new User({ name: 'Bucketer', email: 'hello@buckets.io', password: 'S3cr3ts' })
        u.upsertRole 'contributor', bucket, (e, user) ->
          throw e if e

          bucket.getMembers (e, users) ->
            throw e if e

            assert.isArray(users)
            assert.lengthOf(users, 1)
            assert.equal(users[0].id, u.id)

            done()
