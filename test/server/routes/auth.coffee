serverPath = '../../../server'

config = require "#{serverPath}/config"
User = require "#{serverPath}/models/user"

reset = require '../../reset'
app = require(serverPath)().app

request = require 'supertest'

{expect} = require 'chai'

describe 'Auth routes', ->
  before (done) ->
    User.create
      name: 'Test Admin'
      email: 'test+admin@buckets.io'
      password: 'testing123'
    , done

  after reset.db

  describe 'POST /login', (done) ->
    it 'logs in with correct credentials and redirects to /admin/', (done) ->
      request app
        .post "/#{config.adminSegment}/login"
        .send
          username: 'test+admin@buckets.io'
          password: 'testing123'
        .expect 302
        .end (err, res) ->
          expect(err).to.not.exist
          expect(res.header.location).to.equal '/admin/'
          done()

    it 'redirects to /admin/login with incorrect credentials', (done) ->
      request app
        .post "/#{config.adminSegment}/login"
        .send
          username: 'test+admin@buckets.io'
          password: 'testing456'
        .expect 302
        .end (err, res) ->
          expect(err).to.not.exist
          expect(res.header.location).to.equal('/admin/login')
          done()

  describe 'POST /checkLogin (AJAX-based login check)', ->
    it 'returns a 200 if authentication succeeds', (done) ->
      request app
        .post "/#{config.adminSegment}/checkLogin"
        .send
          username: 'test+admin@buckets.io'
          password: 'testing123'
        .expect 200
        .end done

    it 'returns a 401 (with errors) if authentication fails', (done) ->
      request app
        .post "/#{config.adminSegment}/checkLogin"
        .send
          username: 'test+admin@buckets.io'
          password: 'testing456'
        .expect 401
        .end (err, res) ->
          expect(err).to.not.exist
          expect(res.body.errors[0].path).to.equal('password')
          done()
