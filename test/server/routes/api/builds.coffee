{expect} = require 'chai'
request = require 'supertest'
fs = require 'fs-extra'
buckets = require '../../../../server'
app = buckets().app
config = require('../../../../server/config')
Build = require '../../../../server/models/build'
auth = require '../../../auth'
reset = require '../../../reset'

describe 'REST#Builds', ->
  @timeout 4000

  before (done) -> buckets -> reset.db -> buckets().generateBuilds done

  describe 'GET /builds/', ->
    it 'returns a 401 if user isn’t authenticated', (done) ->
      request app
        .get "/#{config.apiSegment}/builds"
        .expect 401
        .end done

    it 'returns a 401 if user isn’t an admin', (done) ->
      auth.createUser (err, user) ->
        user
          .get "/#{config.apiSegment}/builds"
          .expect 401
          .end done

    it 'returns a list of builds for admins', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .get "/#{config.apiSegment}/builds"
          .expect 200
          .end (err, res) ->
            expect(res.body).to.be.an 'Array'
            done()

  # Used to change the env of a build
  describe 'PUT /builds/:id', ->
    stagingBuild = null
    liveBuild = null

    before (done) ->
      reset.builds -> buckets().generateBuilds ->
        Build.find {}, (err, builds) ->
          for build in builds
            if build.env is 'live'
              liveBuild = build
            else if build.env is 'staging'
              stagingBuild = build
          done()

    it 'returns a 401 if user isn’t authenticated', (done) ->
      request app
        .put "/#{config.apiSegment}/builds/#{stagingBuild.id}/"
        .send
          env: 'live'
        .expect 401
        .end done

    it 'returns a 401 if user isn’t an admin', (done) ->
      auth.createUser (err, user) ->
        user
          .put "/#{config.apiSegment}/builds/#{stagingBuild.id}/"
          .send
            env: 'live'
          .expect 401
          .end done

    it 'returns a 404 if build doesn’t exist', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .put "/#{config.apiSegment}/builds/543ae3e1d3ae3a350e4eb924/" # Rando Mongo ID
          .send
            env: 'live'
          .expect 404
          .end done

    it 'returns a 400 if no env is provided', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .put "/#{config.apiSegment}/builds/#{stagingBuild.id}/"
          .expect 400
          .end done

    it 'returns a 500 if build id is wonky', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .put "/#{config.apiSegment}/builds/abc/"
          .send
            env: 'live'
          .expect 500
          .end done

    it 'returns a 200 if build was updated (staging to live) and adds an author', (done) ->

      # First we need to create a diff or the staging build will be rejected
      fs.outputFile "#{config.buildsPath}staging/newfile.txt", 'test', ->
        auth.createAdmin (err, admin) ->
          admin
            .put "/#{config.apiSegment}/builds/#{stagingBuild.id}/"
            .send
              env: 'live'
            .expect 200
            .end (err, res) ->
              Build.findOne env: 'live', (err, build) ->
                expect(stagingBuild.id).to.equal build.id
                done()

    # Archiving happens automatically when a staging/live build is created
    it 'returns a 400 if attempting to change env to archive', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .put "/#{config.apiSegment}/builds/#{stagingBuild.id}/"
          .send
            env: 'archive'
          .expect 400
          .end done

    # Need to edit a file so archive build is created
    describe 'Working with Archives', ->
      it 'returns a 200 if build was updated (archive to staging)'
      it 'returns a 400 if attempting to change archive to live'

  describe 'DELETE /builds/:id', ->
    stagingBuild = null
    liveBuild = null

    before (done) ->
      reset.builds -> buckets().generateBuilds ->
        # todo: Timeout shouldn't be necessary here, need to make sure generateBuilds is fully async
        setTimeout ->
          Build.find {}, (err, builds) ->
            for build in builds
              if build.env is 'live'
                liveBuild = build
              else if build.env is 'staging'
                stagingBuild = build
            done()
        , 1000

    it 'returns a 401 if user isn’t authenticated', (done) ->
      request app
        .delete "/#{config.apiSegment}/builds/#{stagingBuild.id}"
        .expect 401
        .end done

    it 'returns a 401 if user isn’t an admin', (done) ->
      auth.createUser (err, user) ->
        user
          .delete "/#{config.apiSegment}/builds/#{stagingBuild.id}"
          .expect 401
          .end done

    it.skip 'returns a 204 if build was deleted', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .delete "/#{config.apiSegment}/builds/#{archiveBuild.id}"
          .expect 204
          .end done

    it 'returns a 400 if build env is not archive', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .delete "/#{config.apiSegment}/builds/#{stagingBuild.id}"
          .expect 400
          .end done

  describe 'GET /builds/:id/download', ->
    stagingBuild = null
    liveBuild = null

    before (done) ->
      reset.builds -> buckets().generateBuilds ->
        # todo: Timeout shouldn't be necessary here, need to make sure generateBuilds is fully async
        setTimeout ->
          Build.find {}, (err, builds) ->
            for build in builds
              if build.env is 'live'
                liveBuild = build
              else if build.env is 'staging'
                stagingBuild = build
            done()
        , 1000

    it 'returns a 401 if user isn’t authenticated', (done) ->
      request app
        .get "/#{config.apiSegment}/builds/#{stagingBuild.id}/download"
        .expect 401
        .end done

    it 'returns a 401 if user isn’t an admin', (done) ->
      auth.createUser (err, user) ->
        user
          .get "/#{config.apiSegment}/builds/#{stagingBuild.id}/download"
          .expect 401
          .end done

    it 'returns a 404 if build doesn’t exist', (done) ->
      auth.createUser (err, user) ->
        user
          .get "/#{config.apiSegment}/builds/0000000000000/download"
          .expect 401
          .end done

    it 'returns a 200 (download) if build exists', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .get "/#{config.apiSegment}/builds/#{stagingBuild.id}/download"
          .expect 200
          .end (err, res) ->
            expect(res.headers['content-disposition']).to.match /^attachment/
            done()


  describe 'GET /builds/:env(staging|live)/download', ->
    stagingBuild = null
    liveBuild = null

    before (done) ->
      reset.builds -> buckets().generateBuilds ->
        # todo: Timeout shouldn't be necessary here, need to make sure generateBuilds is fully async
        setTimeout ->
          Build.find {}, (err, builds) ->
            for build in builds
              if build.env is 'live'
                liveBuild = build
              else if build.env is 'staging'
                stagingBuild = build
            done()
        , 1000

    it 'returns a 401 if user isn’t authenticated', (done) ->
      request app
        .get "/#{config.apiSegment}/builds/#{stagingBuild.id}/download"
        .expect 401
        .end done

    it 'returns a 401 if user isn’t an admin', (done) ->
      auth.createUser (err, user) ->
        user
          .get "/#{config.apiSegment}/builds/#{stagingBuild.id}/download"
          .expect 401
          .end done

    it 'returns a 404 if build doesn’t exist', (done) ->
      auth.createUser (err, user) ->
        user
          .get "/#{config.apiSegment}/builds/0000000000000/download"
          .expect 401
          .end done

    it 'returns a 200 (download) if build exists', (done) ->
      auth.createAdmin (err, admin) ->
        admin
          .get "/#{config.apiSegment}/builds/#{stagingBuild.id}/download"
          .expect 200
          .end (err, res) ->
            expect(res.headers['content-disposition']).to.match /^attachment/
            done()
