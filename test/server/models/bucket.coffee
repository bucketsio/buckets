User = require('../../../server/models/user')
Bucket = require('../../../server/models/bucket')
db = require('../../../server/lib/database')

reset = require '../../reset'

{assert} = require('chai')

describe 'Bucket', ->

  before reset.db
  after reset.db

  describe '#getMembers', ->
    u = null
    b = null

    before (done) ->
      Bucket.create { name: 'Images', slug: 'images' }, (e, bucket) ->
        throw e if e
        u = new User
          name: 'Bucketer'
          email: 'hello@buckets.io'
          password: 'S3cr3ts'
        b = bucket
        done()

    it 'returns members', (done) ->

        u.upsertRole 'contributor', b, (e, user) ->
          throw e if e
          b.getMembers (e, users) ->
            assert.isArray(users)
            assert.lengthOf(users, 1)
            assert.equal(users[0].id, u.id)

            done()
