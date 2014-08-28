request = require 'supertest'
reset = require '../../reset'

describe 'Frontend Routes', ->
  app = null
  before (done) -> reset.db ->
    app = reset.server done

  describe 'GET /', ->
    # This is temporary, as our default install does not create the "/" Route yet
    it 'returns a 404', (done)->
      request(app).get('/').expect(404, done)
      # But why’s it so slow then?

  describe 'GET /404', ->
    it 'returns a 404', (done)->
      request(app).get('/404').expect(404, done)
