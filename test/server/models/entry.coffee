db = require '../../../server/lib/database'
config = require '../../../server/config'

Entry = require '../../../server/models/entry'
Bucket = require '../../../server/models/bucket'
User = require '../../../server/models/user'

{expect} = require 'chai'

MongoosasticConfig = require 'mongoosastic/test/config'

describe 'Entry', ->

  user = null

  after (done) ->
    db.connection.db.dropDatabase done

  before (done) ->
    User.create
      name: 'Bucketer'
      email: 'hello@buckets.io'
      password: 'S3cr3ts'
    , (e, u) ->
      throw e if e
      user = u
      done()

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
        throw e if e
        bucketId = bucket._id
        done()

    afterEach (done) ->
      Bucket.remove {}, done

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

  describe '#findByParams', ->
    # Set up a bunch of entries to filter/search
    before (done) ->
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

    after (done) ->
      Bucket.remove {}, -> Entry.remove {}, -> setTimeout done, 1200

    it 'filters by bucket slug (empty)', (done) ->
      Entry.findByParams bucket: '', (e, entries) ->
        expect(entries).to.have.length 0
        done()

    it 'filters by bucket slug', (done) ->
      Entry.findByParams bucket: 'photos', (e, entries) ->
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
    # We just create these once since we're only testing search
    # (and we're using a delay to guarantee they're indexed)
    # Yeah, it's pretty gross.
    before (done) ->
      @timeout 5000

      MongoosasticConfig.deleteIndexIfExists [config.elastic_search_index], ->
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
          ], (e, entry1, entry2) ->
            throw e if e

            e1indexed = no
            e2indexed = no

            entry1.on 'es-indexed', -> e1indexed = yes
            entry2.on 'es-indexed', -> e2indexed = yes

            checkIndexed = ->
              if e1indexed and e2indexed
                # Even after being reported as indexed,
                # docs may not be searchable right away
                # The testing gods are crying, I know
                setTimeout done, 1100
                clearInterval interval

            interval = setInterval checkIndexed, 10

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

    it 'searches tags', (done) ->
      Entry.findByParams query: 'summer', (e, entries) ->
        expect(entries).to.have.length 1
        expect(entries?[0]?.title).to.equal 'Test Photoset'
        done()
