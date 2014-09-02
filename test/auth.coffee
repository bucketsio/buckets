request = require 'supertest'

User = require '../server/models/user'
config = require '../server/config'

app = require('../server')().app

module.exports =
  createAdmin: (done) ->
    User.create
      name: 'Test Admin'
      email: 'test+admin@buckets.io'
      password: 'testing123'
      roles: [name: 'administrator']
    , ->
      adminUser = request.agent app
      adminUser
        .post "/#{config.adminSegment}/login"
        .send
          username: 'test+admin@buckets.io'
          password: 'testing123'
        .end (err, res) ->
          done err, adminUser

  createUser: (done) ->
    User.create
      name: 'Test User'
      email: 'test+user@buckets.io'
      password: 'testing123'
    , ->
      user = request.agent app
      user
        .post "/#{config.adminSegment}/login"
        .send
          username: 'test+admin@buckets.io'
          password: 'testing123'
        .end (err, res) ->
          done err, user
