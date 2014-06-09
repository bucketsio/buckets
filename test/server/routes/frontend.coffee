request = require('supertest')
app = require('../../../server')

describe 'GET /', ->
  # This is temporary, as our default install does not create the "/" Route yet
  it 'returns a 404', (done)->
    request(app).get('/').expect(404, done)


describe 'GET /404', ->
  it 'returns a 404', (done)->
    request(app).get('/404').expect(404, done)
