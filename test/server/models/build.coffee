reset = require '../../reset'

Build = require '../../../server/models/build'
buckets = require '../../../server'
config = require '../../../server/lib/config'

fs = require 'fs-extra'
{expect} = require 'chai'

describe 'Model#Build', ->
  @timeout 10000

  before buckets
  beforeEach reset.builds

  describe 'Creation', ->
    # For creation tests we just need to generate the default scaffold once
    it 'Defaults to archive and won’t save', (done) ->
      build = new Build
      build.save (e, build) ->
        expect(e).to.exist
        expect(build).to.not.exist
        done()

    it 'Can save a staging build', (done) ->
      buckets().generateBuilds -> reset.db ->
        build = new Build env: 'staging'
        build.save (e, build) ->
          console.error e if e
          expect(e).to.not.exist
          expect(build.env).to.equal 'staging'
          expect(build.md5).to.not.be.empty
          done()

    it 'Can save a live build', (done) ->
      buckets().generateBuilds -> reset.db ->
        build = new Build env: 'live'
        build.save (e, build) ->
          expect(e).to.not.exist
          expect(build.env).to.equal 'live'
          expect(build.md5).to.not.be.empty
          done()

    it 'Won’t save with md5 conflicts', (done) ->
      buckets().generateBuilds -> reset.db ->
        build = new Build env: 'staging'

        build.save (e, build) ->
          expect(e).to.not.exist

          build2 = new Build env: 'staging'
          build2.save (e, build2) ->
            expect(e).to.exist
            expect(build2).to.be.undefined

            Build.find {}, (e, builds) ->
              expect(builds.length).to.equal 1 # staging/live
              done()

    it 'Changing a build to live writes its FS changes', (done) ->

      # Write a custom file (via FS) to staging and save build
      fs.outputFile "#{config.get('buildsPath')}staging/canary.txt", 'PUSHTEST', ->
        build = new Build env: 'staging'
        build.save (e, build) ->

          # Resave that build as live
          build.env = 'live'
          build.save (e, build) ->
            # Check that the udpated file exist
            fs.readFile "#{config.get('buildsPath')}live/canary.txt", (e, buffer) ->
              expect(buffer.toString()).to.equal 'PUSHTEST'
              done()

  describe 'State management', ->
    beforeEach (done) ->
      reset.builds -> buckets().generateBuilds -> reset.db done

    it 'Saving a staging build to live creates a new staging build', (done) ->
      build = new Build env: 'staging'
      build.save (e, build) ->
        build.env = 'live'
        build.save (e, build) ->

          Build.find (e, builds) ->
            expect(builds.length).to.equal 2
            done()
