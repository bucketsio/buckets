request = require 'supertest'
reset = require '../../../reset'
auth = require '../../../auth'

app = require('../../../../server')().app
config = require '../../../../server/config'
Route = require '../../../../server/models/route'

{expect} = require 'chai'

describe 'REST#Routes', ->

  before reset.db
  afterEach reset.db

  describe 'GET /routes', ->
    it 'returns a 401 if user isn’t authenticated', (done) ->
      request app
        .get "/#{config.apiSegment}/routes"
        .expect 401
        .end done

    it 'returns a 401 if user isn’t an admin', (done) ->
      auth.createUser (err, user) ->
        user
          .get "/#{config.apiSegment}/routes"
          .expect 401
          .end done

    it 'returns a 200 and Routes', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .get "/#{config.apiSegment}/routes"
          .expect 200
          .end done

  describe 'POST /routes', ->
    it 'returns a 401 if user isn’t authenticated', (done) ->
      request app
        .post "/#{config.apiSegment}/routes"
        .send
          urlPattern: '/'
          template: 'index'
        .expect 401
        .end done

    it 'returns a 401 if user isn’t an admin', (done) ->
      auth.createUser (err, user) ->
        user
          .post "/#{config.apiSegment}/routes"
          .send
            urlPattern: '/'
            template: 'index'
          .expect 401
          .end done

    it 'returns a 201 and a Route', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .post "/#{config.apiSegment}/routes"
          .send
            urlPattern: '/'
            template: 'index'
          .expect 201
          .end (err, res) ->
            expect(res.body.id).to.exist
            done()

  describe 'PUT/DELETE', ->
    sampleRoute = null
    beforeEach (done) ->
      Route.create
        urlPattern: '/'
        template: 'index'
      , (e, route) ->
        sampleRoute = route
        done()
    afterEach -> reset.db ->
      sampleRoute = null

    describe 'PUT /routes/:id', ->

      it 'returns a 401 if user isn’t authenticated', (done) ->
        request app
          .put "/#{config.apiSegment}/routes/#{sampleRoute.id}"
          .send
            urlPattern: '/new'
          .expect 401
          .end done

      it 'returns a 401 if user isn’t an admin', (done) ->
        auth.createUser (err, user) ->
          user
            .put "/#{config.apiSegment}/routes/#{sampleRoute.id}"
            .send
              urlPattern: '/new'
            .expect 401
            .end done

      it.skip 'returns a 400 for a validation error', (done) ->
        # Unfortunately this works
        auth.createAdmin (err, admin) ->
          admin
            .put "/#{config.apiSegment}/routes/#{sampleRoute.id}"
            .send
              urlPattern: '...'
            .expect 400
            .end (e, res) ->
              console.log e, res.body.urlPatternRegex
              done()

      it 'returns a 200 and a Route', (done) ->
        auth.createAdmin (err, admin) ->
          admin
            .put "/#{config.apiSegment}/routes/#{sampleRoute.id}"
            .send
              urlPattern: '/new'
            .expect 200
            .end (err, res) ->
              expect(res.body.id).to.exist
              expect(res.body.urlPattern).to.equal '/new'
              done()

    describe 'DELETE /routes/:id', ->

      it 'returns a 401 if user isn’t authenticated', (done) ->
        request app
          .delete "/#{config.apiSegment}/routes/#{sampleRoute.id}"
          .expect 401
          .end done

      it 'returns a 401 if user isn’t an admin', (done) ->
        auth.createUser (err, user) ->
          user
            .delete "/#{config.apiSegment}/routes/#{sampleRoute.id}"
            .expect 401
            .end done

      it 'returns a 204', (done) ->
        auth.createAdmin (err, admin) ->
          admin
            .delete "/#{config.apiSegment}/routes/#{sampleRoute.id}"
            .expect 204
            .end done
