{expect} = require 'chai'

BuildFile = require '../../../server/models/buildfile'
config = require '../../../server/config'
reset = require '../../reset'
fs = require 'fs-extra'

describe 'Model#BuildFile', ->
  before reset.db
  afterEach reset.db

  describe 'Validation', ->
    it 'requires a filename', (done) ->
      buildfile = new BuildFile
      buildfile.save (e, buildfile) ->
        expect(e.errors).to.contain.key 'filename'
        expect(buildfile).to.not.exist
        done()

    it 'resolves relative paths in filename', (done) ->
      buildfile = new BuildFile
        filename: 'pointless/../sample.txt'
      buildfile.save (e, buildfile) ->
        expect(e).to.not.exist
        expect(buildfile.filename).to.equal 'sample.txt'
        done()

    it 'can’t create a directory outside of its sandbox (#quarantine)', (done) ->
      buildfile = new BuildFile
        filename: '../sample.txt'

      buildfile.save (e, buildfile) ->
        expect(e.errors.filename).to.exist
        done()

  describe 'Creation', ->
    buildfile = null
    beforeEach (done) ->
      buildfile = new BuildFile filename: '/sample.txt'
      buildfile.save done
    afterEach -> buildfile = null
    after reset.db

    it 'returns the correct keys', ->
      expect(buildfile.toJSON()).to.have.keys [
        'id'
        'filename'
        'build_env'
        'last_modified'
        'date_created'
      ]

    it 'defaults to staging build_env', ->
      expect(buildfile.build_env).to.equal 'staging'

    it 'removes leading slashes', ->
      expect(buildfile.filename).to.equal 'sample.txt'

  describe 'FS Integration', ->
    it 'writes a file to the FS after saving it', (done) ->
      buildfile = new BuildFile
        filename: 'writetest.txt'
        contents: 'Write test!'

      buildfile.save (e, buildfile) ->
        expect(e).to.not.exist

        expectedPath = "#{config.buildsPath}staging/#{buildfile.filename}"

        fs.exists expectedPath, (exists) ->
          expect(exists).to.be.true

          fs.readFile expectedPath, (e, contents) ->
            expect(contents?.toString()).to.equal 'Write test!'
            fs.remove expectedPath, done

    it 'writes a file after saving, from redis pubsub'

    it 'can rename/move', (done) ->
      buildfile = new BuildFile
        filename: 'first.txt'
        contents: 'Write test!'

      buildfile.save (e, buildfile) ->
        console.log e if e
        buildfile.filename = 'renamed.txt'

        buildfile.save (e, buildfile) ->
          expect(fs.existsSync("#{config.buildsPath}staging/first.txt")).to.be.false
          expect(fs.existsSync("#{config.buildsPath}staging/renamed.txt")).to.be.true
          done()

    describe '#rm', ->
      it 'updates a database entry (with empty contents)', (done) ->
        buildfile = new BuildFile
          filename: 'rmtest.txt'
          contents: 'Sample contents'

        buildfile.save (e, buildfile) ->
          expectedPath = "#{config.buildsPath}staging/#{buildfile.filename}"

          BuildFile.rm 'staging', 'rmtest.txt', (e, buildfile) ->
            expect(e).to.not.exist
            expect(buildfile).to.exist
            expect(buildfile.contents).to.be.undefined
            expect(fs.existsSync(expectedPath)).to.be.false
            done()
