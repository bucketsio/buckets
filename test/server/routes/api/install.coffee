path = require 'path'
request = require 'supertest'

serverPath = path.resolve __dirname, '../../../../server'
User = require "#{serverPath}/models/user"
Bucket = require "#{serverPath}/models/bucket"
Entry = require "#{serverPath}/models/entry"
Route = require "#{serverPath}/models/route"
config = require "#{serverPath}/config"
reset = require '../../../reset'

{expect} = require 'chai'

describe 'Install routes', ->
  app = null
  before (done) -> reset.db ->
    app = reset.server done

  after reset.db

  describe 'Validation', ->

    it 'returns an error if password isn’t valid', (done) ->
      request app
        .post "/#{config.apiSegment}/install"
        .send
          name: 'Test User'
          email: 'user@buckets.io'
          password: '123'
        .expect 400
        .end (err, res) ->
          throw err if err
          expect(err).to.not.exist
          expect(res.body.errors).to.exist
          expect(res.body.errors.password.name).to.equal 'ValidatorError'
          done()

    it 'should not install if a user exists'

  describe 'Installation', ->
    it 'should return a populated user object w/administrator permissions', (done) ->
      request app
        .post "/#{config.apiSegment}/install"
        .send
          name: 'Test User'
          email: 'user@buckets.io'
          password: 'secret123'
        .expect 201
        .end (err, res) ->
          expect(err).to.not.exist
          expect(res.body).to.contain.keys ['email_hash', 'roles', 'id']
          expect(res.body.roles[0].name).to.equal 'administrator'
          done()

    # This also generally tests that sample Buckets were added as well
    it 'should add sample Buckets/Entries', (done) ->
      Entry.find {}, (e, entries)->
        expect(e).to.not.exist
        expect(entries).to.have.length.above 0
        done()

    it 'should add sample Routes', (done) ->
      Route.find {}, (e, routes)->
        expect(e).to.not.exist
        expect(routes).to.have.length.above 0
        done()
