config = require '../../../server/config'
reset = require '../../reset'

Entry = require '../../../server/models/entry'
Bucket = require '../../../server/models/bucket'
User = require '../../../server/models/user'

{expect} = require 'chai'

MongoosasticConfig = require 'mongoosastic/test/config'

describe 'Entry', ->

  user = null

  before (done) ->
    User.create
      name: 'Bucketer'
      email: 'hello@buckets.io'
      password: 'S3cr3ts'
    , (e, u) ->
      throw e if e
      user = u
      done()

  after reset.all

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
      # Create a Bucket to put our Test Entries in
      Bucket.create
        name: 'Articles'
        slug: 'articles'
      , (e, bucket) ->
        throw e if e
        bucketId = bucket._id
        done()

    afterEach reset.db

    it 'parses dates from strings', (done) ->
      Entry.create
        title: 'New Entry'
        publishDate: 'tonight at 9pm'
        bucket: bucketId
        author: user._id
      , (e, entry) ->
        expected = new Date
        expected.setHours 21, 0, 0, 0 # 9pm

        expect(expected.toISOString()).equal(entry.publishDate.toISOString())
        done()

    it 'generates a smart slug', (done) ->
      Entry.create {title: 'Resumés & CVs', bucket: bucketId, author: user._id}, (e, entry) ->
        expect(entry.slug).to.equal 'resumes-and-cvs'
        done()

    it 'automatically sets the publishDate', (done) ->
      Entry.create
        title: 'New Entry'
        bucket: bucketId
        author: user._id
      , (e, entry) ->
        expect(entry.publishDate).to.be.a 'Date'
        done()

  describe '#findByParams', ->
    @timeout 4000 # We do a network call to reset the ES index

    # Set up a bunch of entries to filter/search
    before (done) -> reset.all ->
      Bucket.create [
        name: 'Articles'
        slug: 'articles'
      ,
        name: 'Photos'
        slug: 'photos'
      ], (e, articleBucket, photoBucket) ->
        throw e if e

        Entry.create [
          title: 'Test Article'
          bucket: articleBucket._id
          author: user._id
          status: 'live'
          publishDate: '2 days ago'
        ,
          title: 'Test Photoset'
          bucket: photoBucket._id
          author: user._id
          status: 'live'
        ], done

    after reset.db

    it 'filters by bucket slug (empty)', (done) ->
      Entry.findByParams bucket: '', (e, entries) ->
        expect(entries).to.have.length 2
        done()

    it 'filters by bucket slug', (done) ->
      Entry.findByParams bucket: 'photos', (e, entries) ->
        throw e if e
        expect(entries).to.have.length 1
        expect(entries?[0]?.title).to.equal 'Test Photoset'
        done()

    it 'filters by bucket slug (invalid)', (done) ->
      Entry.findByParams bucket: 'asdf', (e, entries) ->
        throw e if e
        expect(entries).to.have.length 0
        done()

    it 'filters by bucket slug (w/negation)', (done) ->
      Entry.findByParams bucket: '-articles', (e, entries) ->
        expect(entries).to.have.length 1
        expect(entries?[0]?.title).to.equal 'Test Photoset'
        done()

    it 'filters by multiple bucket slugs', (done) ->
      Entry.findByParams bucket: 'photos|articles', (e, entries) ->
        expect(entries).to.have.length 2
        done()

    it 'filters with `since`', (done) ->
      Entry.findByParams since: 'yesterday', (e, entries) ->
        expect(entries).to.have.length 1
        expect(entries?[0]?.title).to.equal 'Test Photoset'
        done()

    it 'filters with `until`', (done) ->
      Entry.findByParams until: 'yesterday', (e, entries) ->
        expect(entries).to.have.length 1
        expect(entries?[0]?.title).to.equal 'Test Article'
        done()

  describe 'Search', ->
    before (done) ->
      @timeout 5000

      reset.all ->
        Bucket.create [
          name: 'Articles'
          slug: 'articles'
        ,
          name: 'Photos'
          slug: 'photos'
        ], (e, articleBucket, photoBucket) ->
          throw e if e

          Entry.create [
            title: 'Test Article'
            bucket: articleBucket._id
            author: user._id
            status: 'live'
            publishDate: '2 days ago'
          ,
            title: 'Test Photoset'
            bucket: photoBucket._id
            author: user._id
            status: 'live'
            keywords: ['summer']
          ], ->
            # This is super painful, but only way I can
            # think to test a live elasticsearch instance
            Entry.synchronize -> Entry.refresh -> setTimeout done, 2000

    it 'performs a fuzzy search with `search`', (done) ->
      Entry.findByParams search: 'photoste', (e, entries) ->
        expect(entries).to.have.length 1
        expect(entries?[0]?.title).to.equal 'Test Photoset'
        done()

    it 'can negate a term', (done) ->
      Entry.findByParams query: '-article', (e, entries) ->
        expect(entries).to.have.length 1
        expect(entries?[0]?.title).to.equal 'Test Photoset'
        done()

    it 'can check for specific attribute', (done) ->
      Entry.findByParams query: '_exists_:keywords', (e, entries) ->
        expect(entries).to.have.length 1
        expect(entries?[0]?.title).to.equal 'Test Photoset'
        done()

    it 'can search for specific attribute', (done) ->
      Entry.findByParams query: 'keywords:summ*', (e, entries) ->
        expect(entries).to.have.length 1
        expect(entries?[0]?.title).to.equal 'Test Photoset'
        done()

    it 'doesn’t throw an exception for bad query', (done) ->
      Entry.findByParams query: 'nokey:(6', (e, entries) ->
        expect(entries).to.have.length 0
        done()

    it 'searches keywords', (done) ->
      Entry.findByParams query: 'summer', (e, entries) ->
        expect(entries).to.have.length 1
        expect(entries?[0]?.title).to.equal 'Test Photoset'
        done()

    it 'searches phrases', (done) ->
      Entry.findByParams query: '"Test Photoset"', (e, entries) ->
        expect(entries).to.have.length 1
        expect(entries?[0]?.title).to.equal 'Test Photoset'
        done()
