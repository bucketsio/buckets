db = require '../../../server/lib/database'
mongoose = require 'mongoose'

Entry = require '../../../server/models/entry'
Bucket = require '../../../server/models/bucket'
User = require '../../../server/models/user'

reset = require '../../reset'

{expect} = require 'chai'

describe 'Entry', ->

  user = null

  before (done) -> reset.db ->
    User.create
      name: 'Bucketer'
      email: 'hello@buckets.io'
      password: 'S3cr3ts'
    , (e, u) ->
      throw e if e
      user = u
      done()

  afterEach reset.db

  describe 'Validation', ->

    it 'requires a bucket', (done) ->
      Entry.create {title: 'Some Entry', author: user._id}, (e, entry) ->
        expect(entry).to.be.undefined
        expect(e).to.be.an 'Object'
        expect(e).to.have.deep.property 'errors.bucket'
        done()

    it 'requires an author', (done) ->
      Entry.create {title: 'Some Entry'}, (e, entry) ->
        expect(entry).to.be.undefined
        expect(e).to.be.an 'Object'
        expect(e).to.have.deep.property 'errors.author'
        done()

  describe 'Creation', ->
    bucketId = null

    beforeEach (done) ->
      Bucket.create {name: 'Articles', slug: 'articles'}, (e, bucket) ->
        bucketId = bucket._id
        done()

    it 'parses dates from strings', (done) ->
      Entry.create
        title: 'New Entry'
        publishDate: 'tonight at 9pm'
        bucket: bucketId
        author: user._id
      , (e, entry) ->
        expected = new Date
        expected.setHours(21, 0, 0, 0)

        expect(expected.toISOString()).equal(entry.publishDate.toISOString())
        done()

    it 'generates a smart slug', (done) ->
      Entry.create {title: 'Resumés & CVs', bucket: bucketId, author: user._id}, (e, entry) ->
        expect(entry.slug).to.equal 'resumes-and-cvs'
        done()

    it 'saves keywords as a trimmed Array', (done) ->
      Entry.create
        title: 'Woohoo entry'
        author: user._id
        bucket: bucketId
        keywords: 'Resumés, work , CVs'
      , (e, entry) ->
        expect(entry.keywords.length).to.equal 3
        expect(entry.keywords[2]).to.equal 'CVs'
        done()

    it 'doesn’t save blank keywords', (done) ->

      Entry.create
        title: 'Some Entry'
        author: user._id
        bucket: bucketId
        keywords: ' ,, '
      , (e, entry) ->
        expect(e).to.not.exist
        expect(entry.keywords).to.be.empty
        # expect(entry).to.be.undefined
        # expect(e).to.have.deep.property 'errors.author'
        done()


  describe '#findByParams', ->
    # Set up a bunch of entries to filter/search
    beforeEach (done) ->
      Bucket.create [
        name: 'Articles'
        slug: 'articles'
      ,
        name: 'Photos'
        slug: 'photos'
      ], (e, articleBucket, photoBucket) ->
        Entry.create [
          title: 'Test Article'
          bucket: articleBucket._id
          author: user._id
          status: 'live'
          publishDate: '2 days ago'
        ,
          title: 'Test Photo'
          bucket: photoBucket._id
          author: user._id
          status: 'live'
        ], ->
          done()

    it 'filters by bucket slug (empty)', (done) ->
      Entry.findByParams bucket: '', (e, entries) ->
        expect(entries).to.have.length 0
        done()

    it 'filters by bucket slug', (done) ->
      Entry.findByParams bucket: 'photos', (e, entries) ->
        expect(entries).to.have.length 1
        expect(entries?[0]?.title).to.equal 'Test Photo'
        done()

    it 'filters by multiple bucket slugs', (done) ->
      Entry.findByParams bucket: 'photos|articles', (e, entries) ->
        expect(entries).to.have.length 2
        done()

    it 'filters with `since`', (done) ->
      Entry.findByParams since: 'yesterday', (e, entries) ->
        expect(entries).to.have.length 1
        expect(entries?[0]?.title).to.equal 'Test Photo'
        done()

    it 'filters with `until`', (done) ->
      Entry.findByParams until: 'yesterday', (e, entries) ->
        expect(entries).to.have.length 1
        expect(entries?[0]?.title).to.equal 'Test Article'
        done()
