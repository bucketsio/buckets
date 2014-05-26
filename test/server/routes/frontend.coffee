request = require('supertest')
app = require('../../../server')

describe 'GET /', ->
  it 'returns a 200', (done)->
    request(app).get('/').expect(200, done)
