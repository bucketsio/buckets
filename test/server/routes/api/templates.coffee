request = require('supertest')
expect = require('chai').expect
sinon = require('sinon')
path = require('path')
serverPath = path.resolve(__dirname, '../../../../server')
fs = require('fs')
Factory = require(path.resolve(__dirname, '../../..', 'factory_wrapper'))
DbTemplate = require(path.resolve(serverPath, 'models/template'))
DbRoute = require(path.resolve(serverPath, 'models/route'))
reset = require '../../../reset'

app = require(serverPath)().app

Template = Factory('template', { filename: 'foo', contents: 'bar' })
Route = Factory('route', { urlPattern: '/foo/bar', template: 'baz' })

describe 'Templates Routes', ->
  before reset.db

  after (done) ->
    DbTemplate.remove {}, (err) ->
      DbRoute.remove {}, done

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
    template = Template.build()

    afterEach (done) ->
      request(app).delete('/api/templates/foo').end(done)

    it 'writes a template', (done) ->
      request(app).post('/api/templates')
        .send(template)
        .set('Content-Type', 'application/json')
        .end (err, res) ->
          expect(err).not.to.exist
          expect(res.status).to.equal(201)
          done();

    it 'handles errors', (done) ->
      sinon.stub(DbTemplate.prototype, 'save', (callback) ->
        callback(new Error('fake error')))

      request(app).post('/api/templates')
        .send({ body: template })
        .end (err, res) ->
          expect(err).not.to.exist
          expect(res.status).to.equal(500)
          DbTemplate.prototype.save.restore()
          done();

  describe 'GET /templates/:filename', ->
    template = Template.build()
    before (done) ->
      request(app).post('/api/templates')
        .send(template)
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
    template = Template.build()
    beforeEach (done) ->
      request(app).post('/api/templates')
        .send(template)
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
    template = Template.build()

    before (done) ->
      request(app).post('/api/templates')
        .send(template)
        .set('Content-Type', 'application/json')
        .end(done)

    after (done) ->
      request(app).delete('/api/templates/foo').end (err, res) ->
        request(app).delete('/api/templates/buzz').end(done)

    it 'updates a template', (done) ->
      update = Template.build({ contents: 'baz' })

      request(app).put('/api/templates/foo')
        .send(update)
        .set('Content-Type', 'application/json')
        .end (err, res) ->
          expect(err).not.to.exist;
          expect(res.status).to.equal(201)
          expect(res.body).to.have.keys ['contents', 'filename']
          done();

    it 'allows renaming', (done) ->
      rename = Template.build({ filename: 'buzz', contents: 'baz' })

      request(app).put('/api/templates/foo')
        .send(rename)
        .set('Content-Type', 'application/json')
        .end (err, res) ->
          expect(err).not.to.exist;
          expect(res.status).to.equal(201)
          request(app).get('/api/templates/foo').end (err, res) ->
            expect(err).not.to.exist;
            expect(res.status).to.equal(404)

            request(app).get('/api/templates/buzz').end (err, res) ->
              expect(err).not.to.exist;
              expect(res.status).to.equal(200)
              expect(res.body.contents).to.equal('baz')
              expect(res.body).to.have.keys ['contents', 'filename']
              done();

  describe 'statics', ->
    route = Route.build()
    template = Template.build()

    before (done) ->
      new DbRoute(route).save((err, r) ->
        request(app).post('/api/templates')
          .send(template)
          .set('Content-Type', 'application/json')
          .end(done)
      )

    after (done) ->
      DbRoute.remove({}, (err) ->
        request(app).delete('/api/templates/foo').end(done)
      )

    it 'renames routes', (done) ->
      DbTemplate.renameRoutes 'baz', 'buzz', (err) ->
        expect(err).not.to.exist
        DbRoute.find {template: 'baz'}, (err, noTemplate) ->
          expect(err).not.to.exist
          expect(noTemplate.length).to.equal(0)
          DbRoute.find {template: 'buzz'}, (err, routes) ->
            expect(err).not.to.exist
            expect(routes.length).to.be.greaterThan(0)
            done()
