User = require('../../../server/models/user')
Bucket = require('../../../server/models/bucket')
db = require('../../../server/lib/database')
{assert} = require('chai')

describe 'User', ->
  beforeEach (done) ->
    for _, c of db.connection.collections
      c.remove(->)
      done()

  afterEach (done) ->
    db.connection.db.dropDatabase done

  describe '#getBuckets', ->
    it 'returns buckets', (done) ->
      Bucket.create { name: 'Images', slug: 'images' }, (e, bucket) ->
        throw e if e

        user = new User({ name: 'Bucketer', email: 'hello@buckets.io', password: 'S3cr3ts' })
        user.upsertRole 'editor', bucket, (e, u) ->
          u.getBuckets (e, buckets) ->
            throw e if e

            assert.isArray(buckets)
            assert.lengthOf(buckets, 1)
            assert.equal(buckets[0].id, bucket.id)

            done()
