request = require('supertest')
expect = require('chai').expect
sinon = require('sinon')
path = require('path')
serverPath = path.resolve(__dirname, '../../../../server')
app = require(serverPath)
fs = require('fs')
DbTemplate = require(path.resolve(serverPath, 'models/template'))

describe 'GET /templates', ->
  it 'gets templates', (done) ->
    request(app).get('/api/templates').end (err, res) ->
      expect(err).not.to.exist
      expect(res.status).to.equal(200)
      expect(res.body.length > 0).to.be.true
      done()

  it 'handles errors', (done) ->
    # Stubbing fs because Template.find is an instance method
    sinon.stub(fs, 'readFile', (file, encoding, callback) ->
      callback(new Error('fake error'))
    )

    request(app).get('/api/templates').end (err, res) ->
      expect(err).not.to.exist
      expect(res.status).to.equal(500)
      fs.readFile.restore()
      done()

describe 'POST /templates', ->
  afterEach (done) ->
    request(app).delete('/api/templates/foo').end(done)

  it 'writes a template', (done) ->
    request(app).post('/api/templates')
      .send({ filename: 'foo', contents: 'bar' })
      .set('Content-Type', 'application/json')
      .end (err, res) ->
        expect(err).not.to.exist
        expect(res.status).to.equal(201)
        done();

  it 'handles errors', (done) ->
    sinon.stub(DbTemplate.prototype, 'save', (callback) ->
      callback(new Error('fake error')))

    request(app).post('/api/templates')
      .send({ body: { filename: 'foo', contents: 'bar' } })
      .end (err, res) ->
        expect(err).not.to.exist
        expect(res.status).to.equal(500)
        DbTemplate.prototype.save.restore()
        done();

describe 'GET /templates/:filename', ->
  before (done) ->
    request(app).post('/api/templates')
      .send({ filename: 'foo', contents: 'bar' })
      .set('Content-Type', 'application/json')
      .end(done)

  after (done) ->
    request(app).delete('/api/templates/foo').end(done)

  it 'gets a template', (done) ->
    request(app).get('/api/templates/foo').end (err, res) ->
      expect(err).not.to.exist
      expect(res.status).to.equal(200)
      expect(res.body.filename).to.equal('foo')
      expect(res.body.contents).to.equal('bar')
      done()

  it 'handles 404s', (done) ->
    request(app).get('/api/templates/notfound').end (err, res) ->
      expect(err).not.to.exist
      expect(res.status).to.equal(404)
      done()

  it 'handles errors', (done) ->
    # Stubbing fs because Template.find is an instance method
    sinon.stub(fs, 'readFile', (file, encoding, callback) ->
      callback(new Error('fake error'))
    )

    request(app).get('/api/templates/foo').end (err, res) ->
      expect(err).not.to.exist
      expect(res.status).to.equal(500)
      fs.readFile.restore()
      done()

describe 'DELETE /templates/:filename', ->
  beforeEach (done) ->
    request(app).post('/api/templates')
      .send({ filename: 'foo', contents: 'bar' })
      .set('Content-Type', 'application/json')
      .end(done)

  afterEach (done) ->
    request(app).delete('/api/templates/foo').end(done)

  it 'deletes a template', (done) ->
    request(app).delete('/api/templates/foo').end (err, res) ->
      expect(err).not.to.exist
      expect(res.status).to.equal(204)
      done()

  it 'does not allow deleting the index', (done) ->
    request(app).delete('/api/templates/index').end (err, res) ->
      expect(err).not.to.exist;
      expect(res.status).to.equal(400)
      done();

  it 'handles errors', (done) ->
    sinon.stub(DbTemplate, 'remove', (query, callback) ->
      callback(new Error('fake error')))

    request(app).delete('/api/templates/foo').end (err, res) ->
      expect(err).not.to.exist
      expect(res.status).to.equal(500)
      DbTemplate.remove.restore()
      done();

describe 'PUT /templates/:filename', ->
  before (done) ->
    request(app).post('/api/templates')
      .send({ filename: 'foo', contents: 'bar' })
      .set('Content-Type', 'application/json')
      .end(done)

  after (done) ->
    request(app).delete('/api/templates/foo').end(done)

  it 'updates a template', (done) ->
    request(app).put('/api/templates/foo')
      .send({ filename: 'foo', contents: 'baz' })
      .set('Content-Type', 'application/json')
      .end (err, res) ->
        expect(err).not.to.exist;
        expect(res.status).to.equal(201)
        done();

  it 'does not allow filename mismatches', (done) ->
    request(app).put('/api/templates/buzz')
      .send({ filename: 'foo', contents: 'baz' })
      .set('Content-Type', 'application/json')
      .end (err, res) ->
        expect(err).not.to.exist;
        expect(res.status).to.equal(400)
        done();
