request = require('supertest')
User = require('../../../../server/models/user')
Bucket = require('../../../../server/models/bucket')
app = require('../../../../server')
db = require('../../../../server/lib/database')
{assert} = require('chai')

describe 'Buckets routes', ->
  before (done) ->
    db.connection.on 'open', ->
      db.connection.db.dropDatabase done

  afterEach (done) ->
    db.connection.db.dropDatabase done

  describe 'GET /buckets/:bucket/members', ->
    #it 'returns the members of a given bucket', (done) ->
      #Bucket.create { name: 'Products', slug: 'products', singular: 'product' }, (e, bucket) ->
        #u = new User({ name: 'Bucketer', email: 'hello@buckets.io', password: 'S3cr3ts' })
        #u.upsertRole bucket, 'editor', (e, user) ->
          #request(app)
            #.get('/api/buckets/' + bucket._id + '/members')
            #.expect(200)
            #.end (e, res) ->
              #throw e if e

              #assert.isArray(res.body)
              #assert.lengthOf(res.body, 1)
              #assert.equal(res.body[0].id, user.id)

              #done()
