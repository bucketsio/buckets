path = require 'path'
request = require 'supertest'

serverPath = path.resolve __dirname, '../../../../server'
User = require "#{serverPath}/models/user"
Bucket = require "#{serverPath}/models/bucket"
reset = require '../../../reset'

{expect} = require 'chai'

describe 'Buckets routes', ->
  app = null

  before (done) ->
    app = reset.server ->
      Bucket.create [
        name: 'Photos'
        slug: 'photos'
      ,
        name: 'Docs'
        slug: 'docs'
      ], done

  after reset.db

  describe 'GET /buckets', ->
    it 'returns a 401 if unauthorized', (done) ->
      request(app)
        .get('/api/buckets')
        .expect(401)
        .end (e, res) ->
          throw e if e
          expect(res.body).to.be.an 'Object'
          done()

      it 'returns 200 with buckets'

    describe 'POST /buckets', ->
      it 'returns a 401 if not logged in', (done) ->
        request(app)
          .post('/api/buckets')
          .expect(401)
          .end (e, res) ->
            throw e if e
            expect(res.body).to.be.an 'Object'
            done()

      it 'returns a 401 if not an admin'
      it 'returns a 200 if bucket is created'

  describe 'GET /buckets/:bucket/members', ->

    # STUB: Need to add auth

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
