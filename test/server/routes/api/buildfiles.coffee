{expect} = require 'chai'
request = require 'supertest'
fs = require 'fs-extra'
buckets = require '../../../../server'
app = buckets().app
config = require('../../../../server/config')
auth = require '../../../auth'
reset = require '../../../reset'

describe 'REST#BuildFiles', ->

  before (done) -> reset.builds ->
    buckets().generateBuilds -> reset.db done

  describe 'GET /buildfiles/:env', ->
    it 'returns a 401 if user isn’t authenticated', (done) ->
      request app
        .get "/#{config.apiSegment}/buildfiles/staging"
        .expect 401
        .end done

    it 'returns a directory of files for admins', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .get "/#{config.apiSegment}/buildfiles/staging"
          .expect 200
          .end (err, res) ->
            expect(err).to.not.exist
            expect(res.body.length).to.equal 4
            for file in res.body
              expect(file).to.have.keys ['filename', 'build_env']
            done()

    it '?type=template returns 200 and templates for admins', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .get "/#{config.apiSegment}/buildfiles/live/?type=template"
          .expect 200
          .end (e, res) ->
            expect(e).to.not.exist
            expect(res.body.length).to.equal 3
            done()

  describe 'GET /buildfiles/:env/:filename', ->
    it 'returns a 401 for anonymous users', (done) ->
      request app
        .get "/#{config.apiSegment}/buildfiles/staging/index.hbs"
        .expect 401
        .end done

    it 'returns a 401 for non-admin users', (done) ->
      auth.createUser (err, user) ->
        user
          .get "/#{config.apiSegment}/buildfiles/staging/index.hbs"
          .expect 401
          .end done

    it 'returns a 404 for non-existent file', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .get "/#{config.apiSegment}/buildfiles/staging/index-nope.hbs"
          .expect 404
          .end done

    it 'returns a 200 and file contents for admins', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .get "/#{config.apiSegment}/buildfiles/staging/index.hbs"
          .expect 401
          .end (e, res) ->
            expect(e).to.be.empty
            expect(res.body).to.have.keys ['filename', 'contents']
            expect(res.body.contents).to.not.be.empty
            done()

    it 'can’t read a file outside of buildsPath', (done) ->
      # Buckets’ index.js
      badPath = '../../../index.js'

      # Pretend it’s in staging, show it exists
      exists = fs.existsSync(config.buildsPath + "staging/" + badPath)
      expect(exists).to.be.true

      auth.createAdmin (err, admin) ->
        admin
          .get "/#{config.apiSegment}/buildfiles/staging/#{encodeURIComponent(badPath)}"
          .expect 403
          .end (e, res) ->
            expect(e).to.be.null
            expect(res.body).to.be.empty
            done()

  describe 'PUT /buildfiles/:env/:filename', ->
    beforeEach reset.db

    it 'returns a 401 if user isn’t authenticated', (done) ->
      request app
        .put "/#{config.apiSegment}/buildfiles/staging/index.hbs"
        .send
          contents: 'New template content.'
        .expect 401
        .end done

    it 'returns a 401 if user isn’t an admin', (done) ->
      auth.createUser (err, user) ->
        user
          .put "/#{config.apiSegment}/buildfiles/staging/index.hbs"
          .send
            contents: 'New template content.'
          .expect 401
          .end done

    it 'returns a 200 if user is an admin', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .put "/#{config.apiSegment}/buildfiles/staging/index.hbs"
          .send
            contents: 'New template content.'
          .expect 200
          .end done

    it 'returns a 200 with a body filename (rename/move)', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .put "/#{config.apiSegment}/buildfiles/staging/index.hbs"
          .send
            filename: 'newfile.hbs'
            contents: 'New template content.'
          .expect 200
          .end (e, res) ->
            expect(e).to.not.exist
            expect(res.body.filename).to.equal 'newfile.hbs'
            done()

    it 'validates Handlebars templates', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .put "/#{config.apiSegment}/buildfiles/staging/index.hbs"
          .send
            contents: '{{#funkyTemplate'
          .expect 400
          .end (e, res) ->
            expect(e).to.not.exist
            expect(res.body.errors.contents).to.have.keys ['line', 'message', 'path']
            done()


  describe 'DELETE /buildfiles/:env/:filename', ->
    beforeEach reset.db

    it 'returns a 401 if user isn’t authenticated', (done) ->
      request app
        .delete "/#{config.apiSegment}/buildfiles/staging/index.hbs"
        .expect 401
        .end done

    it 'returns a 401 if user isn’t an admin', (done) ->
      auth.createUser (err, user) ->
        user
          .delete "/#{config.apiSegment}/buildfiles/staging/index.hbs"
          .expect 401
          .end done

    it 'returns a 204 if user is an admin', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .delete "/#{config.apiSegment}/buildfiles/staging/index.hbs"
          .expect 204
          .end done
