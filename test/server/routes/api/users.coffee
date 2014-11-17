request = require 'supertest'
{assert} = require 'chai'
User = require '../../../../server/models/user'
Bucket = require '../../../../server/models/bucket'
config = require '../../../../server/lib/config'
reset = require '../../../reset'
auth = require '../../../auth'
app = require('../../../../server')().app

{expect} = require 'chai'

describe 'REST#Users', ->
  @timeout 3000

  apiSegment = config.get('apiSegment')
  before reset.db
  afterEach reset.db

  describe 'GET /users', ->
    it 'returns a empty array of users if nothing was found', (done) ->
      request app
        .get "/#{apiSegment}/users"
        .expect 200
          .end (e, res) ->
            users = res.body
            expect(users).to.exist
            assert.isArray(users)
            assert.lengthOf(users, 0)
            done()

    it 'returns a 200 and Users', (done) ->
      auth.createUser (err, user) ->
        user
          .get "/#{apiSegment}/users"
          .expect 200
          .end (e, res) ->
            users = res.body
            expect(users).to.exist
            expect(users).to.be.an 'Array'
            expect(users.length).to.equal 1
            expect(users[0].id).to.exist
            expect(users[0].email).equal('test+user@buckets.io')
            expect(users[0].name).equal('Test User')
            done()

  describe 'POST /users', ->
    it 'returns a 401 if user isn’t authenticated', (done) ->
      request app
        .post "/#{apiSegment}/users"
        .send
          name: 'Phil'
          email: 'phil@buckets.io'
          password: 'plainpassword2014'
        .expect 401
        .end done

    it 'returns a 401 if user isn’t an admin', (done) ->
      auth.createUser (err, user) ->
        user
          .post "/#{apiSegment}/users"
          .send
            name: 'Phil'
            email: 'phil@buckets.io'
            password: 'plainpassword2014'
          .expect 401
          .end done

    it 'returns a 400 if name is empty', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .post "/#{apiSegment}/users"
          .send
            email: 'phil@buckets.io'
            password: 'plainpassword2014'
          .expect 400
          .end done

    it 'returns a 400 if email is empty', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .post "/#{apiSegment}/users"
          .send
            name: 'Phil'
            password: 'plainpassword2014'
          .expect 400
          .end done

    it 'returns a 400 if password is empty', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .post "/#{apiSegment}/users"
          .send
            name: 'Phil'
            email: 'phil@buckets.io'
          .expect 400
          .end done

    it 'returns a 400 if password is less than 6 characters', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .post "/#{apiSegment}/users"
          .send
            name: 'Phil'
            email: 'phil@buckets.io'
            password: 'sh0rt'
          .expect 400
          .end done

    it 'returns a 400 if password is more than 20 characters', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .post "/#{apiSegment}/users"
          .send
            name: 'Phil'
            email: 'phil@buckets.io'
            password: 'extremelylongpassword2014'
          .expect 400
          .end done

    it 'returns a 400 if password doesnot have a number', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .post "/#{apiSegment}/users"
          .send
            name: 'Phil'
            email: 'phil@buckets.io'
            password: 'withoutnumber'
          .expect 400
          .end done

    it 'returns a 200 and User', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .post "/#{apiSegment}/users"
          .send
            name: 'Phil'
            email: 'phil@buckets.io'
            password: 'plainpassword2014'
          .expect 200
          .end (e, res) ->
            user = res.body
            expect(user.id).to.exist
            expect(user.email).equal('phil@buckets.io')
            expect(user.name).equal('Phil')
            done()

    it 'returns a 400 if creating user with duplicate email', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .post "/#{apiSegment}/users"
          .send
            name: 'Peter Johnson'
            email: 'phil@buckets.io'
            password: 'password2014'
          .expect 200
          .end done

    it 'returns a 400 if payload is not JSON', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .post "/#{apiSegment}/users"
          .send 'Invalid JSON payload'
          .expect 400
          .end done

  describe 'GET/PUT/DELETE', ->
    sampleUser = null
    beforeEach (done) ->
      User.create
        name: 'Phil'
        email: 'phil@buckets.io'
        password: 'plainpassword2014'
      , (e, user) ->
        sampleUser = user
        done()
    afterEach -> reset.db ->
      sampleUser = null

    describe 'GET /users/:id', ->

      it 'returns a 200 and User', (done) ->
        request app
          .get "/#{apiSegment}/users/#{sampleUser.id}"
          .expect 200
          .end (e, res) ->
            user = res.body
            expect(user.id).to.exist
            expect(user.email).equal('phil@buckets.io')
            expect(user.name).equal('Phil')
            done()

      it 'returns a 400 if user does not exist', (done) ->
        request app
          .get "/#{apiSegment}/users/0000000000000"
          .expect 400
          .end done

    describe 'PUT /users/:id', ->

      it 'returns a 401 if user isn’t authenticated', (done) ->
        request app
          .put "/#{apiSegment}/users/#{sampleUser.id}"
          .send
            name: 'Phil'
          .expect 401
          .end done

      it 'returns a 401 if user isn’t an admin', (done) ->
        auth.createUser (err, user) ->
          user
            .put "/#{apiSegment}/users/#{sampleUser.id}"
            .send
              name: 'Phil'
            .expect 401
            .end done

      it 'returns a 400 if user does not exist', (done) ->
        auth.createAdmin (err, admin) ->
          admin
            .put "/#{apiSegment}/users/0000000000000"
            .send
              name: 'Phil'
            .expect 400
            .end done

      it 'returns a 200 and updated user', (done) ->
        auth.createAdmin (err, admin) ->
          admin
            .put "/#{apiSegment}/users/#{sampleUser.id}"
            .send
              name: 'Mr. Phil'
            .expect 200
            .end (e, res) ->
              respUser = res.body
              expect(respUser.id).to.exist
              expect(respUser.name).equal('Mr. Phil')
              done()

      # Express automatically will convert the string to an object
      # but the data won’t save.
      it.skip 'returns a 400 if payload is not json', (done) ->
        auth.createAdmin (err, admin) ->
          admin
            .put "/#{apiSegment}/users/#{sampleUser.id}"
            .send 'Invalid JSON payload'
            .expect 400
            .end done

    describe 'DELETE /users/:id', ->

      it 'returns a 401 if user isn’t authenticated', (done) ->
        request app
          .delete "/#{apiSegment}/users/#{sampleUser.id}"
          .expect 401
          .end done

      it 'returns a 401 if user isn’t an admin', (done) ->
        auth.createUser (err, user) ->
          user
            .delete "/#{apiSegment}/users/#{sampleUser.id}"
            .expect 401
            .end done

      it 'returns a 400 if user is not exist', (done) ->
        auth.createAdmin (err, admin) ->
          admin
            .delete "/#{apiSegment}/users/0000000000000"
            .expect 400
            .end done

      it 'returns a 200 and user is gone', (done) ->
        auth.createAdmin (err, admin) ->
          admin
            .delete "/#{apiSegment}/users/#{sampleUser.id}"
            .expect 200
            .end (e, res) ->
              User.findById sampleUser.id, (err, dbUser) ->
                expect(dbUser).to.not.exist
                done()

  describe 'POST /forgot', ->
    it 'returns a 404 if user does not exist', (done) ->
      request app
        .post "/#{apiSegment}/forget"
        .send
          email: 'random@example.com'
        .expect 404
        .end done

    it 'returns a 404 if payload is not json', (done) ->
      request app
        .post "/#{apiSegment}/forgot"
        .send 'Invalid JSON payload'
        .expect 404
        .end done

    it 'returns a 403 if body contains Mongo injection-style $ object key', (done) ->
      badObject = {'$gt': ''}
      r = request app
        .post "/#{apiSegment}/forgot"
        .send
          email: badObject
        .expect 403
        .end (e, res) ->
          expect(res.text).equal('Disallowed object in request: ' + JSON.stringify(badObject))
          done()

  describe 'GET /reset/:token', ->
    it 'returns a 404 if token does not exist', (done) ->
      request app
        .get "/#{apiSegment}/reset/12312213"
        .expect 404
        .end done

  describe 'PUT /reset/:token', ->
    it 'returns a 404 if token does not exist', (done) ->
      request app
        .put "/#{apiSegment}/reset/12312213"
        .expect 404
        .end done
