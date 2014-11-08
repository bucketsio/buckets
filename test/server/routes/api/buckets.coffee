request = require 'supertest'
User = require '../../../../server/models/user'
Bucket = require '../../../../server/models/bucket'
config = require '../../../../server/lib/config'
reset = require '../../../reset'
auth = require '../../../auth'
app = require('../../../../server')().app

{expect} = require 'chai'

describe 'REST#Buckets', ->
  before reset.db
  afterEach reset.db

  describe 'GET /buckets', ->
    it 'returns a 401 if user isn’t authenticated', (done) ->
      request app
        .get "/#{config.get('apiSegment')}/buckets"
        .expect 401
        .end done

    it 'returns a 200 if user isn’t an admin, with accessible Buckets', (done) ->
      auth.createUser (err, user) ->
        user
          .get "/#{config.get('apiSegment')}/buckets"
          .expect 200
          .end done

    it 'returns a 200 and Buckets', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .get "/#{config.get('apiSegment')}/buckets"
          .expect 200
          .end done

  describe 'POST /buckets', ->
    it 'returns a 401 if user isn’t authenticated', (done) ->
      request app
        .post "/#{config.get('apiSegment')}/buckets"
        .send
          name: 'Articles'
          slug: 'articles'
        .expect 401
        .end done

    it 'returns a 401 if user isn’t an admin', (done) ->
      auth.createUser (err, user) ->
        user
          .post "/#{config.get('apiSegment')}/buckets"
          .send
            name: 'Articles'
            slug: 'articles'
          .expect 401
          .end done

    it 'returns a 201 and a Bucket', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .post "/#{config.get('apiSegment')}/buckets"
          .send
            name: 'Articles'
            slug: 'articles'
          .expect 201
          .end (err, res) ->
            expect(res.body.id).to.exist
            done()

  describe 'PUT/DELETE', ->
    sampleBucket = null
    beforeEach (done) ->
      Bucket.create
        name: 'Articles'
        slug: 'articles'
        color: 'green'
      , (e, bucket) ->
        sampleBucket = bucket
        done()
    afterEach -> reset.db ->
      sampleBucket = null

    describe 'PUT /buckets/:id', ->

      it 'returns a 401 if user isn’t authenticated', (done) ->
        request app
          .put "/#{config.get('apiSegment')}/buckets/#{sampleBucket.id}"
          .send
            color: 'red'
          .expect 401
          .end done

      it 'returns a 401 if user isn’t an admin', (done) ->
        auth.createUser (err, user) ->
          user
            .put "/#{config.get('apiSegment')}/buckets/#{sampleBucket.id}"
            .send
              color: 'red'
            .expect 401
            .end done

      it 'returns a 200 and a Bucket', (done) ->
        auth.createAdmin (err, admin) ->
          admin
            .put "/#{config.get('apiSegment')}/buckets/#{sampleBucket.id}"
            .send
              color: 'red'
            .expect 200
            .end (err, res) ->
              expect(res.body.id).to.exist
              done()

    describe 'DELETE /buckets/:id', ->

      it 'returns a 401 if user isn’t authenticated', (done) ->
        request app
          .delete "/#{config.get('apiSegment')}/buckets/#{sampleBucket.id}"
          .expect 401
          .end done

      it 'returns a 401 if user isn’t an admin', (done) ->
        auth.createUser (err, user) ->
          user
            .delete "/#{config.get('apiSegment')}/buckets/#{sampleBucket.id}"
            .expect 401
            .end done

      it 'returns a 204', (done) ->
        auth.createAdmin (err, admin) ->
          admin
            .delete "/#{config.get('apiSegment')}/buckets/#{sampleBucket.id}"
            .expect 204
            .end done

    describe 'REST#Members', ->
      describe 'GET /buckets/:bucketId/members', ->
        it 'returns a 401 if user isn’t authenticated', (done) ->
          request app
            .get "/#{config.get('apiSegment')}/buckets/#{sampleBucket.id}/members"
            .expect 401
            .end done

        it 'returns a 401 if user isn’t an admin', (done) ->
          auth.createUser (err, user) ->
            user
              .get "/#{config.get('apiSegment')}/buckets/#{sampleBucket.id}/members"
              .expect 401
              .end done

        it 'returns a 200', (done) ->
          auth.createAdmin (err, admin) ->
            admin
              .get "/#{config.get('apiSegment')}/buckets/#{sampleBucket.id}/members"
              .expect 200
              .end (e, res) ->
                expect(res.body).to.exist
                done()
