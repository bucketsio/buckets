request = require('supertest')
app = require('../../../server')

describe 'GET /', ->
  it 'returns a 200', (done)->
    request(app).get('/').expect(200, done)


describe 'GET /404', ->
  it 'returns a 404', (done)->
    request(app).get('/404').expect(404, done)
