serverPath = '../../../server'

config = require "#{serverPath}/config"

app = require(serverPath)().app

request = require 'supertest'

{expect} = require 'chai'

describe 'Admin routes', ->
  describe 'GET /admin/', (done) ->
    it 'loads the admin panel', (done) ->
      request app
        .get "/#{config.adminSegment}/"
        .expect 200
        .end (err, res) ->
          expect(err).to.not.exist
          done()
