# Heavy Build tests, including FS and DB
{expect} = require 'chai'
fs = require 'fs-extra'

buckets = require '../../../server'
config = require '../../../server/config'
BuildFile = require '../../../server/models/buildfile'
Build = require '../../../server/models/build'
reset = require '../../reset'
hbs = require 'hbs'
request = require 'supertest'

describe 'Integration#Builds', ->
  @timeout 5000

  beforeEach (done) ->
    buckets ->
      reset.builds ->
        buckets().generateBuilds ->
          done()

  it 'has live & staging builds by default', (done) ->
    Build.find (e, builds) ->
      expect(builds.length).to.equal 2

      liveBuilds = 0
      stagingBuilds = 0

      for build in builds
        ++stagingBuilds if build.env is 'staging'
        ++liveBuilds if build.env is 'live'

      expect(stagingBuilds).to.equal 1
      expect(liveBuilds).to.equal 1

      done()

  it 'can handle being cleared (re: FS)', (done) ->
    Build.find (e, builds) ->
      expect(builds.length).to.equal 2
      done()

  it 'can handle being generated twice', (done) ->
    buckets().generateBuilds ->
      Build.find (e, builds) ->
        expect(builds.length).to.equal 2
        done()

  # describe 'Startup'
  describe 'Integrity', ->
    it 'moves a UI-edited file from staging to live', (done) ->
      editedFile = new BuildFile
        filename: 'index.hbs'
        contents: 'editedText'

      editedFile.save ->

        # Now get our staging build and save it as live
        Build.findOne env: 'staging', (e, build) ->
          build.env = 'live'
          build.save ->
            # Edited text should now be in live
            fs.readFile "#{config.buildsPath}live/index.hbs", (err, buffer) ->
              expect(buffer.toString()).to.equal 'editedText'

              # Edited text should still be on staging
              fs.readFile "#{config.buildsPath}staging/index.hbs", (err, buffer) ->
                expect(buffer.toString()).to.equal 'editedText'

                # There should be 3 builds and no buildfiles
                Build.find (err, builds) ->
                  expect(builds.length).to.equal 3 # live/staging/archive (of old live)

                  BuildFile.count (err, count) ->
                    expect(count).to.equal 0
                    done()

    it 'moves a UI-deleted file from staging to live', (done) ->
      # Remove error.hbs
      BuildFile.rm 'staging', 'error.hbs', ->
        Build.findOne env: 'staging', (e, build) ->
          build.env = 'live'
          build.save ->
            # Live should not have an error.hbs now
            fs.exists "#{config.buildsPath}live/error.hbs", (exists) ->
              expect(exists).to.be.false

              # Nor should staging
              fs.exists "#{config.buildsPath}staging/error.hbs", (exists) ->
                expect(exists).to.be.false

                # There should be 3 builds and no buildfiles
                Build.find (err, builds) ->
                  expect(builds.length).to.equal 3

                  # live/staging/archive (of old live)
                  buildCounts =
                    live: 0
                    staging: 0
                    archive: 0
                  buildCounts[build.env]++ for build in builds

                  expect(count).to.equal(1) for key, count of buildCounts

                  BuildFile.count (err, count) ->
                    expect(count).to.equal 0
                    done()

    it 'clears BuildFiles when pushing staging to live', (done) ->
      # console.log 'TEST START'.rainbow
      BuildFile.create
        filename: 'layout.hbs'
        contents: 'NewLayout'
        build_env: 'live'
      , ->

        # Promote staging to live
        Build.getStaging (e, build) ->
          build.env = 'live'

          build.save (e, build) ->
            BuildFile.find (e, buildfiles) ->
              expect(buildfiles.length).to.equal 0
              done()


    it 'clears the internal HBS view cache when live is updated', (done) ->
      # Manually turn on view caching
      app = buckets().app
      app.set 'view cache', true

      # Cache is empty by default
      expect(hbs.cache).to.be.empty

      # Load the homepage
      request buckets().app
        .get '/'
        .end (e, res) ->
          expect(e).to.be.null

          # Cache is no longer empty
          expect(hbs.cache).to.not.be.empty

          # Create edit, promote to live
          BuildFile.create
            filename: 'layout.hbs'
            contents: 'NewLayout'
            build_env: 'live'
          , ->
            # Promote staging to live
            Build.getStaging (e, build) ->
              build.env = 'live'

              build.save (e, build) ->
                # Cache is empty again
                expect(hbs.cache).to.be.empty
                done()
